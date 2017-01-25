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

	wm geometry $::gaussianVMD::topGui 400x560+$x+25
	$::gaussianVMD::topGui configure -background {white}
	wm resizable $::gaussianVMD::topGui 0 0

	# Procedure when the window is closed
	wm protocol $::gaussianVMD::topGui WM_DELETE_WINDOW {gaussianVMD::quit}

	## Apply theme
	ttk::style theme use gaussianVMDTheme
	
	##########################################################


	#### Top Section
	pack [ttk::frame $gaussianVMD::topGui.frame0 -style gaussianVMD.TFrame]
	pack [canvas $gaussianVMD::topGui.frame0.topSection -bg white -width 400 -height 50 -highlightthickness 0] -in $gaussianVMD::topGui.frame0 

	place [ttk::frame $gaussianVMD::topGui.frame0.topSection.topMenu -width 400 -style gaussianVMD.menuBar.TFrame] -in $gaussianVMD::topGui.frame0.topSection -x 0 -y 0 -width 400 -height 35

	place [ttk::menubutton $gaussianVMD::topGui.frame0.topSection.topMenu.file -text "File" -menu $gaussianVMD::topGui.frame0.topSection.topMenu.file.menu \
			-style gaussianVMD.menuBar.TMenubutton \
			] -in $gaussianVMD::topGui.frame0.topSection.topMenu -x 5 -y 5 -height 25 -width 50
    
	menu $gaussianVMD::topGui.frame0.topSection.topMenu.file.menu -tearoff 0
	$gaussianVMD::topGui.frame0.topSection.topMenu.file.menu add command -label "Open" -command {gaussianVMD::guiOpenFile}
	$gaussianVMD::topGui.frame0.topSection.topMenu.file.menu add command -label "Save" -command {gaussianVMD::guiSaveFile}
	$gaussianVMD::topGui.frame0.topSection.topMenu.file.menu add command -label "Restart" -command {gaussianVMD::restart}
	$gaussianVMD::topGui.frame0.topSection.topMenu.file.menu add command -label "Quit" -command {gaussianVMD::quit}

	place [ttk::menubutton $gaussianVMD::topGui.frame0.topSection.topMenu.import -text "Import" -menu $gaussianVMD::topGui.frame0.topSection.topMenu.import.menu \
			-style gaussianVMD.menuBar.TMenubutton \
			] -in $gaussianVMD::topGui.frame0.topSection.topMenu -x 54 -y 5 -height 25 -width 70
	
	menu $gaussianVMD::topGui.frame0.topSection.topMenu.import.menu -tearoff 0
	$gaussianVMD::topGui.frame0.topSection.topMenu.import.menu add command -label "Import AMBER parameters and connectivity (.prmtop)" -command {gaussianVMD::guiError "This feature is not available yet."}
	$gaussianVMD::topGui.frame0.topSection.topMenu.import.menu add command -label "Import connectivity from Gaussian Input File (.com)" -command {gaussianVMD::guiError "This feature is not available yet."}

	place [ttk::menubutton $gaussianVMD::topGui.frame0.topSection.topMenu.about -text "About" -menu $gaussianVMD::topGui.frame0.topSection.topMenu.about.menu \
			-style gaussianVMD.menuBar.TMenubutton \
			] -in $gaussianVMD::topGui.frame0.topSection.topMenu -x 320 -y 5 -height 25 -width 70

	menu $gaussianVMD::topGui.frame0.topSection.topMenu.about.menu -tearoff 0
	$gaussianVMD::topGui.frame0.topSection.topMenu.about.menu add command -label "Help" -command {gaussianVMD::guiError "This feature is not available yet."}
	$gaussianVMD::topGui.frame0.topSection.topMenu.about.menu add command -label "Credits" -command {gaussianVMD::guiCredits}


	#### Molecule Selection
	pack [canvas $gaussianVMD::topGui.frame0.molSelection -bg white -width 400 -height 40 -highlightthickness 0] -in $gaussianVMD::topGui.frame0

	variable topMolecule "No molecule"
	variable molinfoList {}
	trace variable ::vmd_initialize_structure w gaussianVMD::updateStructures
	place [ttk::combobox $gaussianVMD::topGui.frame0.molSelection.combo \
			-textvariable gaussianVMD::topMolecule \
			-style gaussianVMD.TCombobox \
			-values "$gaussianVMD::molinfoList" \
			-state readonly \
			] -in $gaussianVMD::topGui.frame0.molSelection -x 5 -y 0 -width 390
	bind $gaussianVMD::topGui.frame0.molSelection.combo <<ComboboxSelected>> {gaussianVMD::activateMolecule}
	
	
	#### Job Title
	pack [canvas $gaussianVMD::topGui.frame0.jobTitle -bg white -width 400 -height 30 -highlightthickness 0] -in $gaussianVMD::topGui.frame0
	place [ttk::label $gaussianVMD::topGui.frame0.jobTitle.labe \
			-text {Job Title:} ] -in $gaussianVMD::topGui.frame0.jobTitle -x 5 -y 5
	
	place [ttk::entry $gaussianVMD::topGui.frame0.jobTitle.entry \
			-style gaussianVMD.TEntry \
			-textvariable gaussianVMD::title ] -in $gaussianVMD::topGui.frame0.jobTitle -x 70 -y 5 -width 320

	
	#### Multiplicity and Gaussian Calculations Setup
	pack [canvas $gaussianVMD::topGui.frame0.multiChargeGaussianCalc -bg white -width 400 -height 40 -highlightthickness 0] -in $gaussianVMD::topGui.frame0
	place [ttk::button $gaussianVMD::topGui.frame0.multiChargeGaussianCalc.chargeMulti \
		    -text "Charge and Multiplicity" \
			-style gaussianVMD.TButton \
			-command {gaussianVMD::guiChargeMulti}] -in $gaussianVMD::topGui.frame0.multiChargeGaussianCalc -x 5 -y 5 -width 190

	place [ttk::button $gaussianVMD::topGui.frame0.multiChargeGaussianCalc.gaussianCalc \
		    -text "Calculation Setup" \
			-style gaussianVMD.TButton \
			-command {gaussianVMD::guiError "This feature is not available yet."}] -in $gaussianVMD::topGui.frame0.multiChargeGaussianCalc -x 205 -y 5 -width 190


	#### Tabs
	pack [canvas $gaussianVMD::topGui.frame0.tabs -bg white -width 400 -height 400 -highlightthickness 0] -in $gaussianVMD::topGui.frame0
	place [ttk::notebook $gaussianVMD::topGui.frame0.tabs.tabsAtomList] -in $gaussianVMD::topGui.frame0.tabs -x 5 -y 5 -width 390 -height 390

	# Tabs Names
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -background white] -text "Tools"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2] -text "Layer"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3] -text "Freeze"
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList add [frame $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4] -text "Charges"

	# Choose active tab
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList select $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1

	# Tab Visualization
	place [ttk::label $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.quickRepLabel \
			-text {Representantions} \
			-style gaussianVMD.centerLabel.TLabel \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 0 -y 5 -width 390

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.showHL \
			-text "High Layer" \
			-variable gaussianVMD::HLrep \
			-command {gaussianVMD::onOffRepresentation 2} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 30 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.showML \
			-text "Medium Layer" \
			-variable gaussianVMD::MLrep \
			-command {gaussianVMD::onOffRepresentation 3} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 138 -y 30 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.showLL \
			-text "Low Layer" \
			-variable gaussianVMD::LLrep \
			-command {gaussianVMD::onOffRepresentation 4} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 271 -y 30 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.unfreeze \
			-text "Unfreeze" \
			-variable gaussianVMD::unfreezeRep \
			-command {gaussianVMD::onOffRepresentation 8} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 55 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.freezeMinusOne \
			-text "Freeze" \
			-variable gaussianVMD::freezeRep \
			-command {gaussianVMD::onOffRepresentation 9} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 138 -y 55 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.all \
			-text "All" \
			-variable gaussianVMD::allRep \
			-command {gaussianVMD::onOffRepresentation 13} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 271 -y 55 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.protein \
			-text "Protein" \
			-variable gaussianVMD::proteinRep \
			-command {gaussianVMD::onOffRepresentation 5} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 80 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.nonProtein \
			-text "Non-Protein" \
			-variable gaussianVMD::nonproteinRep \
			-command {gaussianVMD::onOffRepresentation 6} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 138 -y 80 -width 123

	place [ttk::checkbutton $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.water \
			-text "Water" \
			-variable gaussianVMD::waterRep \
			-command {gaussianVMD::onOffRepresentation 7} \
			-style gaussianVMD.TCheckbutton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 271 -y 80 -width 123

	place [ttk::label $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.quickToolsLabel \
			-text {Tools} \
			-style gaussianVMD.centerLabel.TLabel \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 0 -y 120 -width 390

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.resetView \
			-text "Reset View" \
			-command {display resetview} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 150 -width 180

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.centerAtom \
			-text "Center on atom" \
			-command {mouse mode center} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 200 -y 150 -width 180

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.showRepresentantionWindow \
			-text "Representantions" \
			-command {menu graphics on} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 190 -width 180

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.deleteAllLabels \
			-text "Delete all labels" \
			-command {gaussianVMD::deleteAllLabels} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 200 -y 190 -width 180

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.mouseModeRotate \
			-text "Rotate" \
			-command {mouse mode rotate} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 230 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.mouseModeTranslate \
			-text "Translate" \
			-command {mouse mode translate} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 133 -y 230 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.mouseModeScale \
			-text "Scale" \
			-command {mouse mode scale} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 261 -y 230 -width 118

	place [ttk::label $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.editorLabel \
			-text {Structure Manipulation} \
			-style gaussianVMD.centerLabel.TLabel \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 0 -y 280 -width 390

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.bondEdit \
			-text "Bond" \
			-command {gaussianVMD::bondModifInitialProc} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 5 -y 310 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.angleEdit \
			-text "Angle" \
			-command {gaussianVMD::angleModifInitialProc} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 133 -y 310 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1.dihedralEdit \
			-text "Dihedral" \
			-command {gaussianVMD::dihedModifInitialProc} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab1 -x 261 -y 310 -width 118

	
	# Charges Tab
	place [tablelist::tablelist $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer \
			-showeditcursor true \
			-columns {0 "Index" center 0 "Gaussian Atom" center 0 "Resname" center 0 "Resid" center 0 "Charges" center} \
			-stretch all \
			-background white \
			-yscrollcommand [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.yscb set] \
			-xscrollcommand [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.xscb set] \
			-selectmode extended \
			-height 14 \
			-state normal \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4 -x 0 -y 0 -width 370 -height 300

	place [ttk::scrollbar $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.yscb \
			-orient vertical \
			-command [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer yview]\
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4 -x 370 -y 0 -width 20 -height 300

	place [ttk::scrollbar $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.xscb \
			-orient horizontal \
			-command [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer xview]\
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4 -x 0 -y 300 -height 20 -width 370

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.clearSelection \
			-text "Clear Selection" \
			-command {gaussianVMD::clearSelection charges} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4 -x 5 -y 325 -width 380

	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer configcolumns 4 -editable true

	bind $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer <<TablelistSelect>> {gaussianVMD::changeRepCurSelection charges}

	# Layer Tab
	place [tablelist::tablelist $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer\
			-showeditcursor true \
			-columns {0 "Index" center 0 "PDB Atom" center 0 "Resname" center 0 "Resid" center 0 "Layer" center} \
			-stretch all \
			-background white \
			-yscrollcommand [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.yscb set] \
			-xscrollcommand [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.xscb set] \
			-selectmode extended \
			-height 14 \
			-state normal \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 0 -y 0 -width 370 -height 240

	place [ttk::scrollbar $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.yscb \
			-orient vertical \
			-command [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer yview]\
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 370 -y 0 -width 20 -height 240

	place [ttk::scrollbar $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.xscb \
			-orient horizontal \
			-command [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer xview]\
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 0 -y 240 -height 20 -width 370

	place [ttk::label $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.selectionLabel \
			-text {Atom selection (Change ONIOM layer):} \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 5 -y 265 -width 380

	place [ttk::entry $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.selection \
			-textvariable gaussianVMD::atomSelectionONIOM \
			-style gaussianVMD.TEntry \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 5 -y 290 -width 375

	place [ttk::combobox $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.selectModificationValue \
			-textvariable gaussianVMD::selectionModificationValueOniom \
			-style gaussianVMD.comboBox.TCombobox \
			-values "[list "H" "M" "L"]" \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 5 -y 320 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.selectionApply \
			-text "Apply" \
			-command {gaussianVMD::applyToStructure oniom} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 133 -y 320 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.clearSelection \
			-text "Clear Selection" \
			-command {gaussianVMD::clearSelection oniom} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2 -x 261 -y 320 -width 118

	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer configcolumns 4 -editable true

	bind $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer <<TablelistSelect>> {gaussianVMD::changeRepCurSelection oniom}

	
	# Freeze Tab
	place [tablelist::tablelist $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer\
			-showeditcursor true \
			-columns {0 "Index" center 0 "PDB Atom" center 0 "Resname" center 0 "Resid" center 0 "Freeze" center} \
			-stretch all \
			-background white \
			-yscrollcommand [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.yscb set] \
			-xscrollcommand [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.xscb set] \
			-selectmode extended \
			-height 14 \
			-state normal \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 0 -y 0 -width 370 -height 240

	place [ttk::scrollbar $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.yscb \
			-orient vertical \
			-command [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer yview]\
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 370 -y 0 -width 20 -height 240

	place [ttk::scrollbar $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.xscb \
			-orient horizontal \
			-command [list $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer xview]\
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 0 -y 240 -height 20 -width 370

	place [ttk::label $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.selectionLabel \
			-text {Atom selection (Change freezing state):} \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 5 -y 265 -width 380

	place [ttk::entry $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.selection \
			-textvariable gaussianVMD::atomSelectionFreeze\
			-style gaussianVMD.TEntry \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 5 -y 290 -width 375

	place [ttk::combobox $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.selectModificationValue \
			-textvariable gaussianVMD::selectionModificationValueFreeze \
			-style gaussianVMD.comboBox.TCombobox \
			-values "[list "0" "-1" "-2" "-3"]" \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 5 -y 320 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.selectionApply \
			-text "Apply" \
			-command {gaussianVMD::applyToStructure freeze} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 133 -y 320 -width 118

	place [ttk::button $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.clearSelection \
			-text "Clear Selection" \
			-command {gaussianVMD::clearSelection freeze} \
			-style gaussianVMD.TButton \
			] -in $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3 -x 261 -y 320 -width 118

	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer configcolumns 4 -editable true

	bind $gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer <<TablelistSelect>> {gaussianVMD::changeRepCurSelection freeze}

}


proc gaussianVMD::getMolinfoList {} {
	set gaussianVMD::molinfoList {}
	
	set a [molinfo top]

	if {$a == -1} {
		set gaussianVMD::topMolecule "No molecule"
	} else {
		set gaussianVMD::topMolecule "[molinfo top] : [molinfo top get name]"

		set list [molinfo list]
		foreach mol $list {
			set molDetails "$mol : [molinfo $mol get name]"
			lappend gaussianVMD::molinfoList $molDetails
		}
	}

	$gaussianVMD::topGui.frame0.molSelection.combo configure -values $gaussianVMD::molinfoList
}


proc gaussianVMD::activateMolecule {} {
	## Set molecule to top
	mol top [lindex $gaussianVMD::topMolecule 0]

	## Delete previous info
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer delete 0 end
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer delete 0 end
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer delete 0 end

	## Add info to tables
	set sel [atomselect top all]
	set index [$sel get index]
	set type [$sel get type]
	set name [$sel get name]
	set resname [$sel get resname]
	set resid [$sel get resid]


	# Index
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer insertlist end $index
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer insertlist end $index
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer insertlist end $index

	# Atom Type
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer columnconfigure 1 -text $type
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer columnconfigure 1 -text $name
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer columnconfigure 1 -text $name

	# Resname
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer columnconfigure 2 -text $resname
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer columnconfigure 2 -text $resname
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer columnconfigure 2 -text $resname
	
	# Resid
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer columnconfigure 3 -text $resid
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer columnconfigure 3 -text $resid
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer columnconfigure 3 -text $resid

	# Specific
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab4.tableLayer columnconfigure 4 -text [$sel get charge] -formatcommand {format %.8s}
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab2.tableLayer columnconfigure 4 -text [$sel get altloc]
	$gaussianVMD::topGui.frame0.tabs.tabsAtomList.tab3.tableLayer columnconfigure 4 -text [$sel get user]
}

proc gaussianVMD::updateStructures {args} {
	set gaussianVMD::allRep "1"

	gaussianVMD::getMolinfoList
	gaussianVMD::activateMolecule
	gaussianVMD::addSelectionRep
}