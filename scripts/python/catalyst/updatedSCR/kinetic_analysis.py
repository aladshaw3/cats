import json
'''
files_to_read = ["250C_model02.json",
                "300C_model02.json",
                "350C_model02.json",
                "400C_model02.json",
                "450C_model02.json",
                "500C_model02.json",
                "550C_model02.json"]
'''
'''
files_to_read = ["250C_model02.json",
                "300C_model02.json",
                "350C_model03.json",
                "400C_model03.json",
                "450C_model03.json",
                "500C_model02.json",
                "550C_model03.json"]

'''
files_to_read = ["250C_model02.json",
                "300C_model02.json",
                "350C_model03.json",
                "400C_model04.json",
                "450C_model03.json",
                "500C_model02.json",
                "550C_model04.json"]


T_list = [250+273.15,300+273.15,350+273.15,400+273.15,450+273.15,500+273.15,550+273.15]

rxn_list = ["r5f", "r5r", "r6f", "r6r", "r7", "r8", "r9", "r10", "r11", "r12",
            "r13", "r14", "r15", "r16", "r17", "r18", "r19", "r20", "r21", "r22", "r23",
            "r24", "r25", "r26", "r27", "r28", "r29", "r30", "r31", "r32", "r33", "r34",
            "r35", "r36", "r37", "r38", "r39"]

k_values = [0.0]*len(rxn_list)

file = open("param_table2.txt","w")
file.write("T (oC)")
for rxn in rxn_list:
    file.write("\t"+rxn)
file.write('\n')

t=0
for file_name in files_to_read:
    print("working on k values for "+ file_name + "...")
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

    t+=1

file.close()

species = ["NH3","NO","NO2"]
ages = ["Unaged","2hr","4hr","8hr","16hr"]
temps = ["250C","300C","350C","400C","450C","500C","550C"]

data_conv = {}  #temp, species, age, time --> value
model_conv = {}
time_windows = {} #temp, age, type --> (start, stop)

t=0
for file_name in files_to_read:
    print("working on conversions for "+ file_name + "...")
    obj = json.load(open(file_name))
    data_conv[temps[t]] = {}
    model_conv[temps[t]] = {}
    time_windows[temps[t]] = {}

    #obj['model']['Cb']["('NH3', 'Unaged', '550C', 0, 0)"]
    for spec in species:
        data_conv[temps[t]][spec] = {}
        model_conv[temps[t]][spec] = {}

        for age in ages:
            data_conv[temps[t]][spec][age] = {}
            model_conv[temps[t]][spec][age] = {}
            time_windows[temps[t]][age] = {}
            time_windows[temps[t]][age]["NH3_ox"] = (0,0)
            time_windows[temps[t]][age]["std_SCR"] = (0,0)
            time_windows[temps[t]][age]["fast_SCR"] = (0,0)
            key_in_starter = "('"+spec+"', '"+age+"', '"+temps[t]+"', 0, "
            key_out_starter = "('"+spec+"', '"+age+"', '"+temps[t]+"', 5, "

            for time in obj['model']['t']:
                if time != 0:
                    key_in = key_in_starter+str(time)+")"
                    key_out = key_out_starter+str(time)+")"

                    data_conv[temps[t]][spec][age][time] = (((obj['model']['Cb'][key_in]-obj['model']['Cb_data'][key_out])/obj['model']['Cb'][key_in]))*100
                    model_conv[temps[t]][spec][age][time] = (((obj['model']['Cb'][key_in]-obj['model']['Cb'][key_out])/obj['model']['Cb'][key_in]))*100

            #End model time loop
        #End Age loop
    #End species loop
    t+=1
#End temp loop

# Manually select time windows
for temp in temps:
    for age in ages:

        if temp == "250C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (37,39)
            time_windows[temp][age]["std_SCR"] = (92,98)
            time_windows[temp][age]["fast_SCR"] = (183,187)

        if temp == "250C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (35,38)
            time_windows[temp][age]["std_SCR"] = (87,91)
            time_windows[temp][age]["fast_SCR"] = (158,161)

        if temp == "250C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (37,39)
            time_windows[temp][age]["std_SCR"] = (84,88)
            time_windows[temp][age]["fast_SCR"] = (152,156)

        if temp == "250C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (37,40)
            time_windows[temp][age]["std_SCR"] = (82,86)
            time_windows[temp][age]["fast_SCR"] = (143,148)

        if temp == "250C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (37,39)
            time_windows[temp][age]["std_SCR"] = (78,82)
            time_windows[temp][age]["fast_SCR"] = (137,142)


        if temp == "300C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (31,35)
            time_windows[temp][age]["std_SCR"] = (72,75)
            time_windows[temp][age]["fast_SCR"] = (116,119)

        if temp == "300C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (25,27)
            time_windows[temp][age]["std_SCR"] = (58,61)
            time_windows[temp][age]["fast_SCR"] = (107,110)

        if temp == "300C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (25,28)
            time_windows[temp][age]["std_SCR"] = (57,60)
            time_windows[temp][age]["fast_SCR"] = (100,103)

        if temp == "300C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (25,28)
            time_windows[temp][age]["std_SCR"] = (54,58)
            time_windows[temp][age]["fast_SCR"] = (95,98)

        if temp == "300C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (24,27)
            time_windows[temp][age]["std_SCR"] = (51,54)
            time_windows[temp][age]["fast_SCR"] = (90,93)


        if temp == "350C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (24,27)
            time_windows[temp][age]["std_SCR"] = (49,52)
            time_windows[temp][age]["fast_SCR"] = (79,82)

        if temp == "350C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (23,26)
            time_windows[temp][age]["std_SCR"] = (46,49)
            time_windows[temp][age]["fast_SCR"] = (75,78)

        if temp == "350C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (22,25)
            time_windows[temp][age]["std_SCR"] = (42,45)
            time_windows[temp][age]["fast_SCR"] = (69,72)

        if temp == "350C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (21,24)
            time_windows[temp][age]["std_SCR"] = (39,42)
            time_windows[temp][age]["fast_SCR"] = (65,69)

        if temp == "350C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (22,25)
            time_windows[temp][age]["std_SCR"] = (40,43)
            time_windows[temp][age]["fast_SCR"] = (69,72)


        if temp == "400C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (24,26)
            time_windows[temp][age]["std_SCR"] = (44,46)
            time_windows[temp][age]["fast_SCR"] = (66,68)

        if temp == "400C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (26,28)
            time_windows[temp][age]["std_SCR"] = (49,52)
            time_windows[temp][age]["fast_SCR"] = (76,78)

        if temp == "400C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (26,28)
            time_windows[temp][age]["std_SCR"] = (46,48)
            time_windows[temp][age]["fast_SCR"] = (71,73)

        if temp == "400C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (26,28)
            time_windows[temp][age]["std_SCR"] = (49,51)
            time_windows[temp][age]["fast_SCR"] = (76,78)

        if temp == "400C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (25,28)
            time_windows[temp][age]["std_SCR"] = (50,52)
            time_windows[temp][age]["fast_SCR"] = (74,76)


        if temp == "450C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (30,32)
            time_windows[temp][age]["std_SCR"] = (47,49)
            time_windows[temp][age]["fast_SCR"] = (75,78)

        if temp == "450C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (37,40)
            time_windows[temp][age]["std_SCR"] = (58,60)
            time_windows[temp][age]["fast_SCR"] = (84,86)

        if temp == "450C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (35,38)
            time_windows[temp][age]["std_SCR"] = (65,67)
            time_windows[temp][age]["fast_SCR"] = (96,98)

        if temp == "450C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (38,40)
            time_windows[temp][age]["std_SCR"] = (66,68)
            time_windows[temp][age]["fast_SCR"] = (97,100)

        if temp == "450C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (36,39)
            time_windows[temp][age]["std_SCR"] = (64,66)
            time_windows[temp][age]["fast_SCR"] = (99,101)


        if temp == "500C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (15,17)
            time_windows[temp][age]["std_SCR"] = (28,30)
            time_windows[temp][age]["fast_SCR"] = (52,54)

        if temp == "500C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (39,41)
            time_windows[temp][age]["std_SCR"] = (60,62)
            time_windows[temp][age]["fast_SCR"] = (101,103)

        if temp == "500C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (40,42)
            time_windows[temp][age]["std_SCR"] = (66,68)
            time_windows[temp][age]["fast_SCR"] = (112,114)

        if temp == "500C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (40,42)
            time_windows[temp][age]["std_SCR"] = (65,67)
            time_windows[temp][age]["fast_SCR"] = (125,127)

        if temp == "500C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (37,40)
            time_windows[temp][age]["std_SCR"] = (59,61)
            time_windows[temp][age]["fast_SCR"] = (108,110)


        if temp == "550C" and age == "Unaged":
            time_windows[temp][age]["NH3_ox"] = (11,13)
            time_windows[temp][age]["std_SCR"] = (23,25)
            time_windows[temp][age]["fast_SCR"] = (46,48)

        if temp == "550C" and age == "2hr":
            time_windows[temp][age]["NH3_ox"] = (25,27)
            time_windows[temp][age]["std_SCR"] = (39,41)
            time_windows[temp][age]["fast_SCR"] = (87,89)

        if temp == "550C" and age == "4hr":
            time_windows[temp][age]["NH3_ox"] = (25,27)
            time_windows[temp][age]["std_SCR"] = (39,41)
            time_windows[temp][age]["fast_SCR"] = (92,94)

        if temp == "550C" and age == "8hr":
            time_windows[temp][age]["NH3_ox"] = (24,26)
            time_windows[temp][age]["std_SCR"] = (39,41)
            time_windows[temp][age]["fast_SCR"] = (89,91)

        if temp == "550C" and age == "16hr":
            time_windows[temp][age]["NH3_ox"] = (14,16)
            time_windows[temp][age]["std_SCR"] = (27,29)
            time_windows[temp][age]["fast_SCR"] = (70,72)


results = {} #temp, age, type, spec --> value

for temp in temps:
    results[temp] = {}
    for age in ages:
        results[temp][age] = {}
        for type in time_windows[temp][age]:
            results[temp][age][type] = {}
            for spec in species:
                results[temp][age][type][spec] = {}
                results[temp][age][type][spec]["data"] = 0
                results[temp][age][type][spec]["model"] = 0

for temp in temps:
    for age in ages:
        for spec in species:
            for time in data_conv[temp][spec][age]:
                if time > time_windows[temp][age]["NH3_ox"][0] and \
                            time < time_windows[temp][age]["NH3_ox"][1]:
                    results[temp][age]["NH3_ox"][spec]["data"] = data_conv[temp][spec][age][time]
                    results[temp][age]["NH3_ox"][spec]["model"] = model_conv[temp][spec][age][time]

                if time > time_windows[temp][age]["std_SCR"][0] and \
                            time < time_windows[temp][age]["std_SCR"][1]:
                    results[temp][age]["std_SCR"][spec]["data"] = data_conv[temp][spec][age][time]
                    results[temp][age]["std_SCR"][spec]["model"] = model_conv[temp][spec][age][time]

                if time > time_windows[temp][age]["fast_SCR"][0] and \
                            time < time_windows[temp][age]["fast_SCR"][1]:
                    results[temp][age]["fast_SCR"][spec]["data"] = data_conv[temp][spec][age][time]
                    results[temp][age]["fast_SCR"][spec]["model"] = model_conv[temp][spec][age][time]


types = ["NH3_ox","std_SCR","fast_SCR"]

for type in types:
    for age in ages:
        for spec in species:
            if type == "NH3_ox" and spec != "NH3":
                pass
            else:
                file2 = open("steady_state_conv_of_"+spec+"_at_"+age+"_for_"+type+".txt","w")
                file2.write("T (oC)\tdata\tmodel\n")
                t=0
                for temp in temps:
                    file2.write(str(T_list[t]-273.15)+"\t")
                    file2.write(str(results[temp][age][type][spec]["data"])+"\t")
                    file2.write(str(results[temp][age][type][spec]["model"])+"\n")
                    t+=1
                file2.close()
