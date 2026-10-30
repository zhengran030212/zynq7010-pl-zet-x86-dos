#!/usr/bin/env python3
import re, sys
src = open(sys.argv[1]).read()
instr = {}
seq = 0
for block in src.split('######')[1:]:
    for line in block.split('\n')[1:]:
        parts = line.split()
        if len(parts) < 2: continue
        ins, code = parts[0], parts[1]
        if not (3 <= len(ins) <= 6 and ins.isupper() and '__' in code): break
        instr.setdefault(ins, {'micro':[], 'seq':None})
        instr[ins]['micro'].append(code)
        if instr[ins]['seq'] is None: instr[ins]['seq']=seq; seq+=1
        else: seq+=1
micros=[]; width=None
for name,v in instr.items():
    for i,code in enumerate(v['micro']):
        mi=re.sub('[xdms]','0',code).replace('_','')
        if width is None: width=len(mi)
        elif width!=len(mi): sys.exit(f"{name} bad width")
        last=1 if i==len(v['micro'])-1 else 0
        micros.append(str(last)+mi)
with open('micro_rom.dat','w') as f:
    for m in micros: f.write(m+'\n')
width+=1
j=0
for i in range(len(micros)):
    if i==2**j: j+=1
n=len(micros); z='0'*width
while n<2**j: f.write(z+'\n'); n+=1
print(f"{len(micros)} uinstr, width={width}, addr={j}")
with open('rom_def.v','w') as f:
    f.write(f"`define MICRO_DATA_WIDTH {width}\n`define MICRO_ADDR_WIDTH {j}\n\n")
    for name,v in instr.items():
        f.write(f"`define {name}\t{j}'b{v['seq']:0{j}b}\n")
