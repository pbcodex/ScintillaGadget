;Coloration Syntaxique & Pliage de code

EnableExplicit

Enumeration Highlight
  #Style_Space
  #Style_Comment
  #Style_NonKeyword
  #Style_Keyword
  #Style_FoldKeyword
  #Style_Constant
  #Style_String
  #Style_Integer
  #Style_Operator
  
  #Style_FoldKeywordUp
  #Style_FoldKeywordDown
EndEnumeration

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
Global SciPos.l, SciLine.l, SciCol.l, SciIndent.l

;Liste des mots clés et définition du séparateur
Global KeyWord.s = "ButtonGadget|TextGadget|If|EndIf|Enumeration|EndEnumeration|Procedure|EndProcedure|Select|EndSelect|Case|Default"
Global KeyWordFoldingUp.s = "Procedure|Enumeration|If"
Global KeyWordfoldingDown.s = "EndProcedure|EndEnumeration|EndIf"
Global KeyWordSep.s = "|"

;-Plan de l'application
Declare Start()

Declare MainFormShow() 
Declare MainFormResize()
Declare MainFormClose()

Declare ScintillaCallBack(Gadget, *scinotify.SCNotification)
Declare ScintillaProperties(Gadget)
Declare ScintillaGetLineEndPosition(Gadget, Line)
Declare ScintillaLineFromPosition(Gadget, Pos)

Declare KeyWord(Key.s)
Declare Highlight(Gadget.l, EndPos.l)


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
  OpenWindow(#MainForm,  0,  0, 1024, 768, "ScintillaGadget : Autocompletion", WindowStyle)
  
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
  
  ;If InitScintilla()
    ;@ScintillaCallBack() est une procédure callback qui recevra  les évènements émis par ScintillaGadget
    ScintillaGadget(#Editor, 10, 40, 1004, 668, @ScintillaCallBack())
    ScintillaProperties(#Editor)
    SetActiveGadget(#Editor)
  ;EndIf
  
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

Procedure MainFormClose()
  End
EndProcedure

;-
;- U.T. Utilitaire
Procedure MakeUTF8Text(Text.s)
  Static Buffer.s
  Buffer = Space(StringByteLength(Text, #PB_UTF8) + 1)
  PokeS(@buffer, text, -1, #PB_UTF8)
  ProcedureReturn @buffer
EndProcedure

;-
;- U.T. Scintilla
Procedure ScintillaCallBack(Gadget, *scinotify.SCNotification)
  Protected SciCurrentPos, SciWordStartPos
  
  Select *scinotify\nmhdr\code		  
    Case #SCN_CHARADDED
      
      ;Indentation
      If *scinotify\ch = 13 ;Touche entrée
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
      
      ;Autocomplétion
      Select *scinotify\ch
        Case 'a' To 'z'         
          ;Affichage du mot selectionné si autocomplétion
          SciCurrentPos = ScintillaSendMessage(0, #SCI_GETCURRENTPOS)
          SciWordStartPos = ScintillaSendMessage(0, #SCI_WORDSTARTPOSITION, SciCurrentPos, 1)
          ScintillaSendMessage(0, #SCI_AUTOCSHOW, SciCurrentPos - SciWordStartPos, MakeUTF8Text(KeyWord))
          
      EndSelect
      
    Case #SCN_STYLENEEDED
      Highlight(Gadget, *scinotify\position)
      
    Case #SCN_MARGINCLICK
      ScintillaSendMessage(Gadget, #SCI_TOGGLEFOLD, ScintillaSendMessage(Gadget, #SCI_LINEFROMPOSITION, *scinotify\Position))
      
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
  ;Style par defaut du gadget scintilla (Couleur de fond et de caractére, police .....)
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_DEFAULT, RGB(0, 0, 0))           ;Couleur des caracteres du ScintillaGadget
  ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, RGB(250, 250, 210))     ;Couleur de fond du ScintillaGadget
  ScintillaSendMessage(Gadget, #SCI_STYLESETFONT,#STYLE_DEFAULT, @"Lucida Console")       ;Police à utiliser 
  ScintillaSendMessage(Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT, 10)                     ;Taille de la police
  ScintillaSendMessage(Gadget, #SCI_STYLECLEARALL)
  
  ;Activation et couleur de la ligne en cours d'édition
  ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, #True)
  ScintillaSendMessage(Gadget, #SCI_SETCARETLINEBACK, RGB(255, 228, 181))
  
  ;Les tabulations sont remplacées par des espaces 
  ScintillaSendMessage(Gadget, #SCI_SETUSETABS, #False)
  
  ;Nombre d'espaces pour une tabulation
  ScintillaSendMessage(Gadget, #SCI_SETINDENT, 4)
  
  ;Affichage de la colone de numérotation des lignes
  ScintillaSendMessage(Gadget, #SCI_SETMARGINTYPEN, 0, #SC_MARGIN_NUMBER)                
  ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 0, 50)                               ;Largeur de la colonne
  ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_LINENUMBER, RGB(169, 169, 169))  ;Couleur de fond 
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_LINENUMBER, RGB(250, 250, 210))  ;Couleur des numéros
  
  ;Affichage de la colonne de pliages de code
  ScintillaSendMessage(Gadget, #SCI_SETMARGINMASKN, 2, #SC_MASK_FOLDERS)
  ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 2, 20)
  ScintillaSendMessage(Gadget, #SCI_SETMARGINSENSITIVEN, 2, #True)
  
  ;Parametres de la liste d'autocomplétion des mots clés 
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETMAXHEIGHT, 40)
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETMAXWIDTH, 150)
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETAUTOHIDE, #True)
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETCHOOSESINGLE, #True)
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETIGNORECASE, #True)
  
  ;Caractére séparant chaque mot de la liste des mots clés
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETSEPARATOR, Asc(KeyWordSep))
  
  ;Caractére sélectionnant le mot de la liste d'autocomplétion
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETFILLUPS, 0, @" ")
  
  ;Tri de la liste d'autocomplétion
  ScintillaSendMessage(Gadget, #SCI_AUTOCSETORDER, #SC_ORDER_PERFORMSORT) 
    
  ;Coloration syntaxique
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_Comment, RGB(0, 187, 0))
  ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, #Style_Comment, 1)
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_NonKeyword, RGB(0, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_Keyword, RGB(0, 102, 102))
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_Constant, RGB(169, 64, 147))
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_String, RGB(255, 139, 37))
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_Integer, RGB(255, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #Style_Operator, RGB(205, 92, 92))
    
  ;Choix des icones de pliages du code 
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPEN, #SC_MARK_CIRCLEMINUS)
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDER, #SC_MARK_CIRCLEPLUS)
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERSUB, #SC_MARK_VLINE)
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERTAIL, #SC_MARK_LCORNERCURVE)
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEREND, #SC_MARK_CIRCLEPLUSCONNECTED)
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDEROPENMID, #SC_MARK_CIRCLEMINUSCONNECTED)
  ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #SC_MARKNUM_FOLDERMIDTAIL, #SC_MARK_TCORNERCURVE)
  
  ;Couleur des icones de pliages de code
  ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDER, RGB(255, 255, 255))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDER, RGB(0, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #SC_MARKNUM_FOLDEROPEN, RGB(255, 255, 255))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPEN, RGB(0, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDEROPENMID, RGB(0, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERSUB, RGB(0, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERTAIL, RGB(0, 0, 0))
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #SC_MARKNUM_FOLDERMIDTAIL, RGB(0, 0, 0))
EndProcedure

Procedure ScintillaGetLineEndPosition(Gadget, Line)
  ProcedureReturn ScintillaSendMessage(Gadget, #SCI_GETLINEENDPOSITION, Line)
EndProcedure

Procedure ScintillaLineFromPosition(gadget, Pos)
  ProcedureReturn ScintillaSendMessage(Gadget, #SCI_LINEFROMPOSITION, Pos)
EndProcedure

;-
;- U.T. Coloration syntaxique
Procedure KeyWord(Key.s)
  Protected n
  
  If Key=""
    ProcedureReturn -1
  EndIf
  
  For n = 1 To CountString(KeyWordFoldingUp, KeyWordSep) + 1
    If LCase(StringField(KeyWordFoldingUp, n, KeyWordSep)) = LCase(Key)
      ProcedureReturn #Style_FoldKeywordUp
    EndIf
  Next
  
  For n=1 To CountString(KeyWordFoldingDown, KeyWordSep) + 1
    If LCase(StringField(KeyWordFoldingDown, n, KeyWordSep)) = LCase(Key)
      ProcedureReturn #Style_FoldKeywordDown
    EndIf
  Next
  
  For n=1 To CountString(KeyWord, KeyWordSep) + 1
    If LCase(StringField(KeyWord, n, KeyWordSep)) = LCase(Key)
      ProcedureReturn #Style_Keyword
    EndIf
  Next
  
  ProcedureReturn -1
EndProcedure


Procedure Highlight(Gadget.l, EndPos.l)
  Protected Level = #SC_FOLDLEVELBASE, Char.i, keyword.s, StyleID.i
  Protected ThisLevel.i = Level
  Protected NextLevel.i = Level
  Protected CurrentPos.i = 0, EndLinePos.i,  LineNumber.i, StartKeyword.i
  
  EndPos = ScintillaGetLineEndPosition(Gadget, ScintillaLineFromPosition(Gadget, EndPos))
  ScintillaSendMessage(Gadget, #SCI_STARTSTYLING, CurrentPos, $1F | #INDICS_MASK)
  
  While CurrentPos <= EndPos
    Char = ScintillaSendMessage(Gadget, #SCI_GETCHARAT, CurrentPos)
    
    Select Char
      Case Asc(#LF$)
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, 1, #Style_NonKeyword)
        ScintillaSendMessage(Gadget, #SCI_SETFOLDLEVEL, LineNumber , ThisLevel)
        ThisLevel = NextLevel
        LineNumber + 1
        
      Case '+', '-', '/', '*', '=', '>', '<'
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, 1, #Style_Operator)
        
      Case '0' To '9'
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, 1, #Style_Integer)
        
      Case 'a' To 'z', 'A' To 'Z', '{', '}'
        EndLinePos = ScintillaGetLineEndPosition(Gadget, ScintillaLineFromPosition(Gadget, currentpos))
        keyword = Chr(char)
        
        While currentpos < EndLinePos
          currentpos + 1
          char = ScintillaSendMessage(Gadget, #SCI_GETCHARAT, currentpos)
          If Not ((char >= 'a' And char <= 'z') Or (char >= 'A' And char <= 'Z') Or char = '_'Or (char >= '0' And char <= '9'))
            currentpos-1
            Break
          EndIf
          keyword + Chr(char)
        Wend
        
        Select KeyWord(keyword)
          Case #Style_FoldKeywordUp
            StyleID = #Style_Keyword
            ThisLevel | #SC_FOLDLEVELHEADERFLAG
            NextLevel + 1
            
          Case #Style_FoldKeywordDown
            StyleID = #Style_Keyword
            NextLevel - 1
            If NextLevel < #SC_FOLDLEVELBASE
              NextLevel = #SC_FOLDLEVELBASE
            EndIf
            
          Case #Style_Keyword
            StyleID = #Style_Keyword
            
          Default
            StyleID = #Style_NonKeyword
            
        EndSelect
        
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, Len(keyword), StyleID)
        
      Case '"'
        EndLinePos = ScintillaGetLineEndPosition(Gadget, ScintillaLineFromPosition(Gadget, currentpos))
        StartKeyword = 1
        While currentpos < EndLinePos
          currentpos + 1
          StartKeyword + 1
          If ScintillaSendMessage(Gadget, #SCI_GETCHARAT, currentpos) = '"'
            Break
          EndIf
        Wend
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, StartKeyword, #Style_String)
        
      Case ';'
        EndLinePos = ScintillaGetLineEndPosition(Gadget, ScintillaLineFromPosition(Gadget, currentpos))
        StartKeyword = 1
        While currentpos < EndLinePos
          currentpos + 1
          StartKeyword + 1
        Wend
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, StartKeyword, #Style_Comment)
        
      Case 9, ' '
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, 1, #Style_Space)
        
      Case '#'
        EndLinePos = ScintillaGetLineEndPosition(Gadget, ScintillaLineFromPosition(Gadget, currentpos))
        StartKeyword = 1
        While currentpos < EndLinePos
          currentpos + 1
          char = ScintillaSendMessage(Gadget, #SCI_GETCHARAT, currentpos)
          If Not ((char >= 'a' And char <= 'z') Or (char >= 'A' And char <= 'Z') Or char = '_' Or (char >= '0' And char <= '9'))
            currentpos-1
            Break
          EndIf
          StartKeyword + 1
        Wend
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, StartKeyword, #Style_Constant)
        
      Default
        ScintillaSendMessage(Gadget, #SCI_SETSTYLING, 1, #Style_NonKeyword)
        
    EndSelect
    currentpos+1
  Wend 
EndProcedure
