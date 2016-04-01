;Customisation minimum

EnableExplicit

Enumeration Form
  #Mainform
  #StatusBar
EndEnumeration
  
Enumeration Menu
  #MainMenu
  
  #Quit
EndEnumeration

Enumeration Gadget  
  #Editor
EndEnumeration

;-Déclaration variable et procédures 
Global WindowStyle.i=#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_ScreenCentered|#PB_Window_SizeGadget

;Scintilla 
Global SciPos.l, SciLine.l, SciCol.l, SciIndent.l, SciFile.s, SciText.s

;-Plan de l'application
Declare Start()

Declare MainFormShow() 
Declare MainFormResize()
Declare MainFormClose()

Declare ScintillaCallBack(Gadget, *scinotify.SCNotification)
Declare ScintillaProperties(Gadget)

Start()

;Début
Procedure Start()
  MainFormShow()
  
  BindEvent(#PB_Event_SizeWindow, @MainFormResize(), #MainForm)
  BindEvent(#PB_Event_CloseWindow, @MainFormClose(), #MainForm)
  
  BindMenuEvent(#MainMenu, #Quit, @MainFormClose())
  
  Repeat : WaitWindowEvent(10) : ForEver
EndProcedure

;-
;- U.T. Fenetres, Menu, Gadgets
Procedure MainFormShow()  
  OpenWindow(#MainForm,  0,  0, 1024, 768, "Pure Basic Editor", WindowStyle)
  
  ;Barre de status
  If CreateStatusBar(#StatusBar,WindowID(#Mainform))
    AddStatusBarField(150)
    AddStatusBarField(450) 
  EndIf 
  
  ;Evite le scintillement du Scintilla gadget lors du redimentionnement de la fenetre 
  SmartWindowRefresh(#Mainform, #True)
  
  ;Menu de l'application
  CreateMenu(#mainmenu,WindowID(#MainForm))
  MenuTitle("Fichier")
  MenuItem(#Quit,"Quitter")
  
  If InitScintilla()
    ;@ScintillaCallBack() est une procédure callback qui recevra  les évènements émis par ScintillaGadget
    ScintillaGadget(#Editor, 10, 40, 1004, 668, @ScintillaCallBack())
    ScintillaProperties(#Editor) ;Customisation de l'éditeur
    SetActiveGadget(#Editor)
  EndIf
    
  ;Neutraliser la touche TAB et les caractéres spéciaux
  RemoveKeyboardShortcut(#Mainform, #PB_Shortcut_Tab)
  
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_B, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_G, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_E, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_R, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_O, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_P, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_Q, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_S, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_F, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_H, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_K, 0)
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_W, 0)  
  AddKeyboardShortcut(#Mainform, #PB_Shortcut_Control+#PB_Shortcut_N, 0)
EndProcedure

;Redimensionnement de la fenetre principale
Procedure MainFormResize()
  ResizeGadget(#Editor, #PB_Ignore, #PB_Ignore, WindowWidth(#MainForm)-20, WindowHeight(#Mainform)-100)
EndProcedure

;Fin
Procedure MainFormClose()
  End
EndProcedure

;-
;- U.T. Scintilla
Procedure ScintillaCallBack(Gadget, *scinotify.SCNotification)
  
  Select *scinotify\nmhdr\code		  
    Case #SCN_CHARADDED
      
      ;Il y a t'il une indentation à faire aprés avoir presser la touche Entrée ?
		  If *scinotify\ch = 13
        ;Determination de l'indentation : SciIndent retourne le numéro de colonne  
        SciIndent = ScintillaSendMessage(Gadget, #SCI_GETLINEINDENTATION, SciLine)
        
        ;Mise en place dans la nouvelle ligne indenté : Passage à la ligne suivante et positionnement à la colonne précédente 
		    ScintillaSendMessage(Gadget, #SCI_SETLINEINDENTATION, SciLIne+1, SciIndent)
    
        ;Vous avez pressé la touche entrée mais sans indentation : Le curseur ne passera pas à la ligne suivante.
        ;On va forcer le passage à la ligne en insérant la longueur de #CRLF
        If SciIndent=0 
          SciPos = SciPos + Len(#CRLF$)
        EndIf
    
        ;Positionnement du curseur 
        ScintillaSendMessage(Gadget, #SCI_GOTOPOS, SciPos+SciIndent)
        
      EndIf    
  EndSelect
    
  ;Determination de la position à l'intérieur de la chaine scintilla  
  SciPos = ScintillaSendMessage(Gadget, #SCI_GETANCHOR)
  
  ;Determination de la ligne en cours 
  SciLine = ScintillaSendMessage(Gadget, #SCI_LINEFROMPOSITION, SciPos)
  
  ;Determination de la colonne en cours
  SciCol = ScintillaSendMessage(Gadget, #SCI_GETCOLUMN, SciPos)
  
  ;Determination de l'indentation
  SciIndent = ScintillaSendMessage(Gadget, #SCI_GETLINEINDENTATION, SciLine)
  
  ;Affichage du numéro de ligne/colonne dans la barre de status
  StatusBarText(#StatusBar, 1, "Line : " +Str(SciLine+1)+ "  Col : "+Str(SciCol+1), #PB_StatusBar_Center)  
EndProcedure

;Customisation de l'éditeur
Procedure ScintillaProperties(Gadget)
  Protected SciMarginSizeDefault = 40
  
  ;Style par defaut du gadget scintilla
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_DEFAULT, RGB(0, 0, 0))       ;Couleur des caracteres du ScintillaGadget
  ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, RGB(250, 250, 210)) ;Couleur de fond du ScintillaGadget
  ScintillaSendMessage(Gadget, #SCI_STYLESETFONT,#STYLE_DEFAULT, @"Lucida Console") 
  ScintillaSendMessage(Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT, 10)
  ScintillaSendMessage(Gadget, #SCI_STYLECLEARALL)
  
  ;Activation et couleur de la ligne en cours d'édition
  ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, #True)
  ScintillaSendMessage(Gadget, #SCI_SETCARETLINEBACK, RGB(255, 228, 181))
  
  ;Les tabulations sont remplacées par des espaces 
  ScintillaSendMessage(Gadget, #SCI_SETUSETABS, #False)
  
  ;Nombre d'espaces pour une tabulation
  ScintillaSendMessage(Gadget, #SCI_SETINDENT, 4)
  
  ;Affichage de la colone de numérotation des lignes
  ;0 est l'indice de la premiere colonne.
  ScintillaSendMessage(Gadget, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER) 
  ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 0, SciMarginSizeDefault)
  ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_LINENUMBER, RGB(169, 169, 169))
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_LINENUMBER, RGB(250, 250, 210))
EndProcedure
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 154
; FirstLine = 125
; Folding = --
; EnableUnicode
; EnableXP