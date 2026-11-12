#!/usr/bin/env python3
"""Summarize existing species reports into a registry-wide readable text table.

Run from the gene-function-registry root:
    python3 scripts/summarize_reports_wDate.py
    python3 scripts/summarize_reports_wDate.py --output registry_summary.txt
"""
import argparse
from datetime import date
from pathlib import Path
import re
import sys

HEADINGS = {
    'gene_symbols': 'gene_symbols',
    'gene_model_full_id': 'gene_models',
    'PMID': 'citations',
    'Ontology accession': 'ontology',
}
FIELDS = ('gene_symbols', 'gene_models', 'citations', 'ontology')
COLUMNS = ('Genus', 'Species', 'Total Unique Gene_Symbols',
           'Total Unique gene_models', 'Total Unique Citations',
           'Total Unique Ontology accessions (Traits)')


def read_report(path):
    values = {field: set() for field in FIELDS}
    found = set()
    section = None
    skipped = []
    lines = path.read_text(encoding='utf-8').splitlines()
    report_dates = [date.fromisoformat(match.group(1))
                    for line in lines
                    if (match := re.fullmatch(
                        r'Status for .+ as of (\d{4}-\d{2}-\d{2}):',
                        line.strip()))]
    if len(report_dates) != 1:
        raise ValueError(f'{path}: expected exactly one valid report generation date; found {len(report_dates)}')
    report_date = report_dates[0]
    for line_number, line in enumerate(lines, start=1):
        if line.startswith('Count  '):
            section = None
            for heading, field in HEADINGS.items():
                if line.startswith('Count  ' + heading):
                    section = field
                    found.add(field)
                    break
            continue
        if section is None or not re.match(r'^ *\d+[ \t]+', line):
            continue
        # Preserve trailing tabs: strip() would remove the empty identifier.
        parts = line.lstrip().split('\t')
        if len(parts) < 2 or not parts[1].strip():
            skipped.append(line_number)
            continue
        if section in ('gene_symbols', 'gene_models', 'ontology'):
            key = parts[1].strip()
            if key and key not in ('null', 'N/A'):
                values[section].add(key)
        elif section == 'citations':
            if len(parts) < 4:
                raise ValueError(f'{path}:{line_number}: malformed citation row: {line!r}')
            pmid, doi, citation = (p.strip() for p in parts[1:4])
            if pmid not in ('', 'N/A', 'null'):
                key = ('pmid', pmid)
            elif doi not in ('', 'N/A', 'null'):
                key = ('doi', doi.lower())
            else:
                key = ('citation', citation)
            if key[1] and key[1] not in ('N/A', 'null'):
                values[section].add(key)
    if skipped:
        print(f'Warning: {path}: skipped {len(skipped)} row(s) with blank identifiers at lines {skipped}', file=sys.stderr)
    # The report generator omits citation/ontology headers when those sections
    # have no entries. Treat them as empty, but require the first two sections.
    missing = {'gene_symbols', 'gene_models'} - found
    if missing:
        raise ValueError(f'{path}: missing required sections: {sorted(missing)}')
    return values, report_date


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path('.'),
                        help='Registry root (default: current directory)')
    parser.add_argument('--output', type=Path, default=Path('Stats/registry_summary.txt'),
                        help='Text output file (default: Stats/registry_summary.txt)')
    args = parser.parse_args()
    paths = sorted(args.root.glob('*/*/gene_functions/*.report.txt'))
    if not paths:
        parser.error('No *.report.txt files found under Genus/Species/gene_functions')

    rows = []
    report_dates = []
    all_values = {field: set() for field in FIELDS}
    summed = {field: 0 for field in FIELDS}
    for path in paths:
        genus, species = path.parts[-4:-2]
        values, report_date = read_report(path)
        report_dates.append(report_date)
        counts = {field: len(values[field]) for field in FIELDS}
        rows.append((genus, species, *(counts[field] for field in FIELDS)))
        for field in FIELDS:
            all_values[field].update(values[field])
            summed[field] += counts[field]

    rows.append(('TOTAL (registry-wide unique)', '',
                 *(len(all_values[field]) for field in FIELDS)))
    rows.append(('SUM OF SPECIES', '', *(summed[field] for field in FIELDS)))
    output = args.output
    output.parent.mkdir(parents=True, exist_ok=True)
    # Align columns using their widest header or value, so the plain-text
    # report remains readable in a monospaced editor or terminal.
    widths = [max(len(str(item[i])) for item in [COLUMNS, *rows])
              for i in range(len(COLUMNS))]

    def format_row(row):
        return '  '.join(str(value).ljust(width)
                         for value, width in zip(row, widths)).rstrip()

    separator = '  '.join('-' * width for width in widths)
    with output.open('w', encoding='utf-8') as stream:
        stream.write(f'Registry Summary Stats computed on {date.today().isoformat()}\n')
        earliest, latest = min(report_dates), max(report_dates)
        if earliest == latest:
            stream.write(f'Stats based on Genus reports from {earliest.isoformat()}\n')
        else:
            stream.write(f'Stats based on Genus reports from {earliest.isoformat()} to {latest.isoformat()}\n')
        stream.write('\n')
        stream.write(format_row(COLUMNS) + '\n')
        stream.write(separator + '\n')
        for row in rows[:-2]:
            stream.write(format_row(row) + '\n')
        stream.write(separator + '\n')
        for row in rows[-2:]:
            stream.write(format_row(row) + '\n')
    print(f'Processed {len(paths)} species reports; wrote {output}')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as exc:
        sys.exit(f'Error: {exc}')
