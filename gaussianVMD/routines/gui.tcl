package provide gui 1.0
package require Tk

#### GUI ############################################################
proc gaussianVMD::buildGui {} {

	#### Check if the window exists
	if {[winfo exists $::gaussianVMD::topGui]} {wm deiconify $::gaussianVMD::topGui ;return $::gaussianVMD::topGui}
	toplevel $::gaussianVMD::topGui

	#### Title of the windows
	wm title $gaussianVMD::topGui "Gaussian for VMD v$gaussianVMD::version " ;# titulo da pagina

	#### Change the location of window
	# screen width and height
	set sWidth [expr [winfo vrootwidth  $::gaussianVMD::topGui] -0]
	set sHeight [expr [winfo vrootheight $::gaussianVMD::topGui] -50]

	#window wifth and height
	set wWidth [winfo reqwidth $::gaussianVMD::topGui]
	set wHeight [winfo reqheight $::gaussianVMD::topGui]
	
	display reposition 0 [expr ${sHeight} - 15]
	display resize [expr $sWidth - 400] ${sHeight}

	#wm geometry window $gaussianVMD::topGui 400x590
	set x [expr $sWidth - 2*($wWidth)]

	wm geometry $::gaussianVMD::topGui 400x600+$x+25
	$::gaussianVMD::topGui configure -background {white}
	wm resizable $::gaussianVMD::topGui 0 0

	## Apply theme
	ttk::style theme use clearlooks

	## Styles
	ttk::style configure gaussianVMD.topButtons.TButton \
		-anchor center

	ttk::style configure gaussianVMD.centerLabel.TLabel \
		-anchor center
	
	##########################################################


	#### Top Section
	pack [ttk::frame $gaussianVMD::topGui.frame0]
	pack [canvas $gaussianVMD::topGui.frame0.topSection -bg white -width 400 -height 50 -highlightthickness 0] -in $gaussianVMD::topGui.frame0 


	place [ttk::button $gaussianVMD::topGui.frame0.topSection.openButton \
			-text "OPEN" \
			-command {} \
			-style gaussianVMD.topButtons.TButton] -x 5 -y 5 -in $gaussianVMD::topGui.frame0.topSection -width 90

	place [ttk::button $gaussianVMD::topGui.saveButton \
		    -text "SAVE" \
			-command {} \
			-style gaussianVMD.topButtons.TButton] -x 105 -y 5 -in $gaussianVMD::topGui.frame0.topSection -width 90

	place [ttk::button $gaussianVMD::topGui.restartButton \
		    -text "RESTART" \
			-command {gaussianVMD::restart} \
			-style gaussianVMD.topButtons.TButton] -x 205 -y 5 -in $gaussianVMD::topGui.frame0.topSection -width 90

	place [ttk::button $gaussianVMD::topGui.quitButton \
		    -text "QUIT" \
			-command {gaussianVMD::quit} \
			-style gaussianVMD.topButtons.TButton] -x 305 -y 5 -in $gaussianVMD::topGui.frame0.topSection -width 90


	#### Job Title
	pack [canvas $gaussianVMD::topGui.frame0.jobTitle -bg white -width 400 -height 30 -highlightthickness 0] -in $gaussianVMD::topGui.frame0
	place [ttk::label $gaussianVMD::topGui.frame0.jobTitle.labe \
			-text {Job Title:} ] -in $gaussianVMD::topGui.frame0.jobTitle -x 5 -y 5
	
	place [ttk::entry $gaussianVMD::topGui.frame0.jobTitle.entry \
			-textvariable gaussianVMD::title ] -in $gaussianVMD::topGui.frame0.jobTitle -x 70 -y 5 -width 320

	
	#### Multiplicity and Gaussian Calculations Setup
	pack [canvas $gaussianVMD::topGui.frame0.multiChargeGaussianCalc -bg white -width 400 -height 40 -highlightthickness 0] -in $gaussianVMD::topGui.frame0
	place [ttk::button $gaussianVMD::topGui.frame0.multiChargeGaussianCalc.chargeMulti \
		    -text "Charge and Multiplicity" \
			-style gaussianVMD.topButtons.TButton \
			-command {}] -in $gaussianVMD::topGui.frame0.multiChargeGaussianCalc -x 5 -y 5 -width 190

	place [ttk::button $gaussianVMD::topGui.frame0.multiChargeGaussianCalc.gaussianCalc \
		    -text "Calculation Setup" \
			-style gaussianVMD.topButtons.TButton \
			-command {}] -in $gaussianVMD::topGui.frame0.multiChargeGaussianCalc -x 205 -y 5 -width 190


	#### Tabs
	pack [canvas $gaussianVMD::topGui.frame0.tabs -bg white -width 400 -height 300 -highlightthickness 0] -in $gaussianVMD::topGui.frame0
	place [ttk::notebook $gaussianVMD::topGui.frame0.tabs.tabsAtomList] -in $gaussianVMD::topGui.frame0.tabs -x 5 -y 5 -width 390 -height 290

	# Tabs Names
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1] -text "Visualization"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2] -text "Layer"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3] -text "Freeze"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4] -text "Charges"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab5] -text "Tools"

	# Choose active tab
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList select $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1

	# Tab Visualization
	place [ttk::label $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.quickRepLabel \
			-text {Quick Representantions} \
			-style gaussianVMD.centerLabel.TLabel \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 5 -width 390

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.showHL \
			-text "High Layer" \
			-variable gaussianVMD::HLrep \
			-command {gaussianVMD::onOffRepresentation 2} \
			-style gaussianVMD.QuickRep.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 30 -width 123

}