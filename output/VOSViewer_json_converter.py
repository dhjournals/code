import json
import argparse
from pathlib import Path
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-i', '--input-file', dest='input_file', type=Path, required=True)
parser.add_argument('-o', '--output-file', dest='output_file', type=str, default=None)
args = parser.parse_args()
input_file = args.input_file
output_file = input_file.name.split('.')[0] + '.json' if not args.output_file else args.output_file

if not input_file.exists():
    print('File di inpute non trovato.')
    sys.exit(0)

list_items = []

with open(input_file) as f:
    headers = [head+'<Total>' if 'weight' == head or 'score' == head else head 
            for head in f.readline().rstrip('\n').split('\t')]
    for line in f.read().splitlines():
        line_parts = line.split('\t')
        tmp_item = {}
        for i, header in enumerate(headers):
            if '<' in header:
                master_header, sub_header = header.strip().replace('>', '').split('<')
                if master_header.lower() == 'weight' or master_header.lower() == 'score':
                    master_header += 's'
                if master_header not in tmp_item:
                    tmp_item[master_header] = {}

                tmp_item[master_header][sub_header] = line_parts[i]
            else:
                tmp_item[header] = line_parts[i]
        list_items.append(tmp_item)

final_json = {
    "network": {
        "items": list_items,
        "links": []
    }
}

with open(output_file, 'w') as f:
    json.dump(final_json, f)
