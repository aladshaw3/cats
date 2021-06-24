import json

files_to_read = ["250C_model02.json",
                "300C_model02.json",
                "350C_model02.json",
                "400C_model02.json",
                "450C_model02.json",
                "500C_model02.json",
                "550C_model02.json"]

T_list = [250+273.15,300+273.15,350+273.15,400+273.15,450+273.15,500+273.15,550+273.15]

rxn_list = ["r5f", "r5r", "r6f", "r6r", "r7", "r8", "r9", "r10", "r11", "r12",
            "r13", "r14", "r15", "r16", "r17", "r18", "r19", "r20", "r21", "r22", "r23",
            "r24", "r25", "r26", "r27", "r28", "r29", "r30", "r31", "r32", "r33", "r34",
            "r35", "r36", "r37", "r38", "r39"]

k_values = [0.0]*len(rxn_list)

file = open("param_table.txt","w")
file.write("T (oC)")
for rxn in rxn_list:
    file.write("\t"+rxn)
file.write('\n')

t=0
for file_name in files_to_read:
    obj = json.load(open(file_name))
    i=0
    for rxn in rxn_list:
        k_values[i] = obj['model']['A'][rxn]['value']
        i+=1

    file.write(str(T_list[t]-273.15))
    i=0
    for rxn in rxn_list:
        file.write("\t"+str(k_values[i]))
        i+=1
    file.write('\n')

    t+=0

file.close()
