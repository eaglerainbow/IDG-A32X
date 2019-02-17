# A3XX mCDU by Joshua Davidson (it0uchpods)

# Copyright (c) 2019 Joshua Davidson (it0uchpods)

# Lowercase "g" is a degree symbol in the MCDU font.
# wht = white, grn = green, blu = blue, amb = amber, yel = yellow
var left1 = [props.globals.initNode("MCDU[0]/F-PLN/left-1", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-1", "", "STRING")];
var left2 = [props.globals.initNode("MCDU[0]/F-PLN/left-2", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-2", "", "STRING")];
var left3 = [props.globals.initNode("MCDU[0]/F-PLN/left-3", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-3", "", "STRING")];
var left4 = [props.globals.initNode("MCDU[0]/F-PLN/left-4", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-4", "", "STRING")];
var left5 = [props.globals.initNode("MCDU[0]/F-PLN/left-5", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-5", "", "STRING")];
var left6 = [props.globals.initNode("MCDU[0]/F-PLN/left-6", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-6", "", "STRING")];
var left7 = ["", ""]; # Not actually used, only for logic
var left1s = [props.globals.initNode("MCDU[0]/F-PLN/left-1s", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-1s", "", "STRING")];
var left2s = [props.globals.initNode("MCDU[0]/F-PLN/left-2s", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-2s", "", "STRING")];
var left3s = [props.globals.initNode("MCDU[0]/F-PLN/left-3s", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-3s", "", "STRING")];
var left4s = [props.globals.initNode("MCDU[0]/F-PLN/left-4s", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-4s", "", "STRING")];
var left5s = [props.globals.initNode("MCDU[0]/F-PLN/left-5s", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-5s", "", "STRING")];
var left6s = [props.globals.initNode("MCDU[0]/F-PLN/left-6s", "", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/left-6s", "", "STRING")];
var line1c = [props.globals.initNode("MCDU[0]/F-PLN/line-1c", "wht", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/line-1c", "wht", "STRING")];
var line2c = [props.globals.initNode("MCDU[0]/F-PLN/line-2c", "wht", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/line-2c", "wht", "STRING")];
var line3c = [props.globals.initNode("MCDU[0]/F-PLN/line-3c", "wht", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/line-3c", "wht", "STRING")];
var line4c = [props.globals.initNode("MCDU[0]/F-PLN/line-4c", "wht", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/line-4c", "wht", "STRING")];
var line5c = [props.globals.initNode("MCDU[0]/F-PLN/line-5c", "wht", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/line-5c", "wht", "STRING")];
var line6c = [props.globals.initNode("MCDU[0]/F-PLN/line-6c", "wht", "STRING"), props.globals.initNode("MCDU[1]/F-PLN/line-6c", "wht", "STRING")];
var showFromInd = [props.globals.initNode("MCDU[0]/F-PLN/show-from", 0, "BOOL"), props.globals.initNode("MCDU[1]/F-PLN/show-from", 0, "BOOL")];

var discontinuity =    "---F-PLN DISCONTINUITY--";
var fpln_end =         "------END OF F-PLN------";
var altn_fpln_end =    "----END OF ALTN F-PLN---";
var no_altn_fpln_end = "------NO ALTN F-PLN-----";

var offset = [0, 0];
var fp = 1;
var num = 0;
var wpColor = "grn";
var page = "";
var offsetThreshold = 6; # 6 WPs for F-PLN, 5 for TMPY F-PLN
var active_out = [nil, props.globals.getNode("/FMGC/flightplan[1]/active")];
var num_out = [props.globals.getNode("/FMGC/flightplan[0]/num"), props.globals.getNode("/FMGC/flightplan[1]/num")];
var TMPYActive = props.globals.getNode("/FMGC/internal/tmpy-active");
var TMPYActive_out = props.globals.initNode("/MCDUC/tmpy-active", 0, "BOOL");
var pageProp = [props.globals.getNode("/MCDU[0]/page", 1), props.globals.getNode("/MCDU[1]/page", 1)];

setlistener("/FMGC/internal/tmpy-active", func {
	if (TMPYActive.getBoolValue()) {
		fp = 0;
		wpColor = "yel";
		offsetThreshold = 5;
	} else {
		fp = 1;
		wpColor = "grn";
		offsetThreshold = 6;
	}
}, 0, 0);

var slewFPLN = func(d, i) {
	if (d == 1) {
		if (left7[i] != "" and offsetThreshold == 6) {
			offset[i] = offset[i] + 1;
		} else if (left6[i].getValue() != "" and offsetThreshold == 5) {
			offset[i] = offset[i] + 1;
		}
	} else if (d == -1) {
		if (offset[i] > 0) {
			offset[i] = offset[i] - 1;
		}
	}
}

var updateFPLN = func(i) {
	page = pageProp[i].getValue();
	
	if (page != "F-PLNA" and page != "F-PLNB") {
		offset[i] = 0; # Reset offset to 0 when no longer viewing F-PLN page
	}
	
	num = num_out[fp].getValue();
	
	if (active_out[1].getBoolValue()) {
#		if (offset[i] + offsetThreshold > num + 2) {
#			if (num + 2 - offsetThreshold >= 0) {
#				offset[i] = num - offsetThreshold;
#			}
#		}
		
		# Line 1:
		if (offset[i] < num) {
			left1[i].setValue(fmgc.wpID[fp][offset[i]].getValue());
			if (offset[i] == fmgc.arrivalAirportI[fp]) {
				left1s[i].setValue("DEST");
				line1c[i].setValue("wht");
			} else {
				left1s[i].setValue("C" ~ math.round(fmgc.wpCoursePrev[fp][offset[i]].getValue()) ~ "g");
				line1c[i].setValue(wpColor);
			}
		} else if (offset[i] == num) {
			left1[i].setValue(fpln_end);
			left1s[i].setValue("");
			line1c[i].setValue("wht");
		} else if (offset[i] == num + 1) {
			left1[i].setValue(no_altn_fpln_end);
			left1s[i].setValue("");
			line1c[i].setValue("wht");
		} else {
			left1[i].setValue("");
		}
		
		# Line 2:
		if (offset[i] + 1 < num) {
			left2[i].setValue(fmgc.wpID[fp][offset[i] + 1].getValue());
			if (offset[i] + 1 == fmgc.arrivalAirportI[fp]) {
				left2s[i].setValue("DEST");
				line2c[i].setValue("wht");
			} else {
				left2s[i].setValue("C" ~ math.round(fmgc.wpCoursePrev[fp][offset[i] + 1].getValue()) ~ "g");
				line2c[i].setValue(wpColor);
			}
		} else if (offset[i] + 1 == num) {
			left2[i].setValue(fpln_end);
			left2s[i].setValue("");
			line2c[i].setValue("wht");
		} else if (offset[i] + 1 == num + 1) {
			left2[i].setValue(no_altn_fpln_end);
			left2s[i].setValue("");
			line2c[i].setValue("wht");
		} else {
			left2[i].setValue("");
		}
		
		# Line 3:
		if (offset[i] + 2 < num) {
			left3[i].setValue(fmgc.wpID[fp][offset[i] + 2].getValue());
			if (offset[i] + 2 == fmgc.arrivalAirportI[fp]) {
				left3s[i].setValue("DEST");
				line3c[i].setValue("wht");
			} else {
				left3s[i].setValue("C" ~ math.round(fmgc.wpCoursePrev[fp][offset[i] + 2].getValue()) ~ "g");
				line3c[i].setValue(wpColor);
			}
		} else if (offset[i] + 2 == num) {
			left3[i].setValue(fpln_end);
			left3s[i].setValue("");
			line3c[i].setValue("wht");
		} else if (offset[i] + 2 == num + 1) {
			left3[i].setValue(no_altn_fpln_end);
			left3s[i].setValue("");
			line3c[i].setValue("wht");
		} else {
			left3[i].setValue("");
		}
		
		# Line 4:
		if (offset[i] + 3 < num) {
			left4[i].setValue(fmgc.wpID[fp][offset[i] + 3].getValue());
			if (offset[i] + 3 == fmgc.arrivalAirportI[fp]) {
				left4s[i].setValue("DEST");
				line4c[i].setValue("wht");
			} else {
				left4s[i].setValue("C" ~ math.round(fmgc.wpCoursePrev[fp][offset[i] + 3].getValue()) ~ "g");
				line4c[i].setValue(wpColor);
			}
		} else if (offset[i] + 3 == num) {
			left4[i].setValue(fpln_end);
			left4s[i].setValue("");
			line4c[i].setValue("wht");
		} else if (offset[i] + 3 == num + 1) {
			left4[i].setValue(no_altn_fpln_end);
			left4s[i].setValue("");
			line4c[i].setValue("wht");
		} else {
			left4[i].setValue("");
		}
		
		# Line 5:
		if (offset[i] + 4 < num) {
			left5[i].setValue(fmgc.wpID[fp][offset[i] + 4].getValue());
			if (offset[i] + 4 == fmgc.arrivalAirportI[fp]) {
				left5s[i].setValue("DEST");
				line5c[i].setValue("wht");
			} else {
				left5s[i].setValue("C" ~ math.round(fmgc.wpCoursePrev[fp][offset[i] + 4].getValue()) ~ "g");
				line5c[i].setValue(wpColor);
			}
		} else if (offset[i] + 4 == num) {
			left5[i].setValue(fpln_end);
			left5s[i].setValue("");
			line5c[i].setValue("wht");
		} else if (offset[i] + 4 == num + 1) {
			left5[i].setValue(no_altn_fpln_end);
			left5s[i].setValue("");
			line5c[i].setValue("wht");
		} else {
			left5[i].setValue("");
		}
		
		# Line 6:
		if (offset[i] + 5 < num) {
			left6[i].setValue(fmgc.wpID[fp][offset[i] + 5].getValue());
			if (offset[i] + 5 == fmgc.arrivalAirportI[fp]) {
				left6s[i].setValue("DEST");
				line6c[i].setValue("wht");
			} else {
				left6s[i].setValue("C" ~ math.round(fmgc.wpCoursePrev[fp][offset[i] + 5].getValue()) ~ "g");
				line6c[i].setValue(wpColor);
			}
		} else if (offset[i] + 5 == num) {
			left6[i].setValue(fpln_end);
			left6s[i].setValue("");
			line6c[i].setValue("wht");
		} else if (offset[i] + 5 == num + 1) {
			left6[i].setValue(no_altn_fpln_end);
			left6s[i].setValue("");
			line6c[i].setValue("wht");
		} else {
			left6[i].setValue("");
		}
		
		# Line 7:
		# Not actually used, only for logic
		if (offset[i] + 6 < num) {
			left7[i] = fmgc.wpID[fp][offset[i] + 6].getValue();
		} else if (offset[i] + 6 == num) {
			left7[i] = fpln_end;
		} else if (offset[i] + 6 == num + 1) {
			left7[i] = no_altn_fpln_end;
		} else {
			left7[i] = "";
		}
		
		if (offset[i] > 0) {
			showFromInd[i].setBoolValue(0);
		} else {
			showFromInd[i].setBoolValue(1);
		}
		
		TMPYActive_out.setBoolValue(TMPYActive.getBoolValue()); # Only engage MCDU TMPY mode once the nessesary flightplan changes have been made.
	} else {
		left1[i].setValue(fpln_end);
		left1s[i].setValue("");
		left2[i].setValue(no_altn_fpln_end);
		left2s[i].setValue("");
		left3[i].setValue("");
		left3s[i].setValue("");
		left4[i].setValue("");
		left4s[i].setValue("");
		left5[i].setValue("");
		left5s[i].setValue("");
		left6[i].setValue("");
		left6s[i].setValue("");
	}
}

# Button and Inputs
var FPLNButton = func(s, key, i) {
	if (s == "L") {
		var input = offset[i] + key - 1; # Where to insert waypoint?
		var scratchpad = getprop("/MCDU[" ~ i ~ "]/scratchpad");
		
		if (key == 6 and TMPYActive_out.getBoolValue()) {
			TMPYActive.setBoolValue(0);
		} else {
			if (scratchpad == "CLR") {
				if (!TMPYActive.getBoolValue()) {
					fmgc.flightplan.initTempFP(1);
				}
				if (fmgc.flightplan.deleteWP(input, 0) != 0) {
					notAllowed(i);
				} else {
					setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 0);
					setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
				}
			} else {
				if (size(scratchpad) == 5) {
					if (!TMPYActive.getBoolValue()) {
						fmgc.flightplan.initTempFP(1);
					}
					if (fmgc.flightplan.insertFix(scratchpad, input, 0) != 0) {
						notInDataBase(i);
					} else {
						setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
					}
				} else if (size(scratchpad) == 4) {
					if (!TMPYActive.getBoolValue()) {
						fmgc.flightplan.initTempFP(1);
					}
					if (fmgc.flightplan.insertArpt(scratchpad, input, 0) != 0) {
						notInDataBase(i);
					} else {
						setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
					}
				} else if (size(scratchpad) == 3) {
					if (!TMPYActive.getBoolValue()) {
						fmgc.flightplan.initTempFP(1);
					}
					if (fmgc.flightplan.insertNavaid(scratchpad, input, 0) != 0) {
						notInDataBase(i);
					} else {
						setprop("/MCDU[" ~ i ~ "]/scratchpad", "");
					}
				} else {
					notAllowed(i);
				}
			}
		}
	} else if (s == "R") {
		if (key == 6 and TMPYActive_out.getBoolValue()) {
			fmgc.flightplan.executeTempFP(1);
		} else {
			notAllowed(i);
		}
	}
}

var notInDataBase = func(i) {
	if (getprop("/MCDU[" ~ i ~ "]/scratchpad") != "NOT IN DATABASE") {
		setprop("/MCDU[" ~ i ~ "]/last-scratchpad", getprop("/MCDU[" ~ i ~ "]/scratchpad"));
	}
	setprop("/MCDU[" ~ i ~ "]/scratchpad-msg", 1);
	setprop("/MCDU[" ~ i ~ "]/scratchpad", "NOT IN DATABASE");
}
