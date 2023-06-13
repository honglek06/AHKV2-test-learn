; REMOVED: #NoEnv
#SingleInstance force
Persistent
#MaxThreadsPerHotkey 1
#Include "Lib/v2/Chrome.ahk"
#Include "Lib/v2/JSON.ahk"
#Requires AutoHotkey >=2.0

;**************************************************
;	G L O B A L - V A R I A B L E S
;**************************************************

gv_debug := 0 ; 0=deactivate, 1=activate
gv_backupDir := "Backup"

; check RegEx option : https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm
;SetTitleMatchMode, RegEx
zWinTitle := "ahk_exe ProjectN-Win64-Shipping.exe"
nino_mappos := []
ctrlMap := Map()
nino_windows := Map()
nino_spamF_flag := -1
alt_LButton_hold := -1
nino_copy_win := []
nino_copy_win_pos := Map()

WM_KEYDOWN := 0x0100
WM_KEYUP := 0x0101
WM_SYSKEYDOWN := 0x0104
WM_SYSKEYUP := 0x0105
WM_LBUTTONDOWN := 0x0201
WM_LBUTTONUP := 0x0202
WM_MOUSEMOVE := 0x0200

; object to keep mapping between username and windows number for each user
username_map := Map( "m-local" , 1, "nino2" , 2, "nino3" , 3, "nino4" , 4, "nino5" , 5, "nino6" , 6, "nino7" , 7, "Nino8" , 8 )

;************** CAUTION *******************
; user/pass list mapping with owner user
userlist := map()

/* <<< --- OBSOLETED : 2021.03.26 --------
;;; To use chrome connect to automate webpage
;;; 1)	the chrome must be open in debug mode
;;; 	because all chrome page open within the same ChromeProfile2 folder will be count as the same session
;;; 	This will not working if one of the page of that profile is already open with non-debug mode
;;; 	so, 
;;; 	*** better create new ChromeProfile2 folder only used for automate only
;;; 	which in this case will create a folder name ChromeProfile2 at the same ahk-script working-directory
;;; 2)	Use the app shortcut feature from chrome to create individual-like app for the page (with shortcut activate)
;;; 3)	The shortcut of that app property will contain the app-id which we will use in the code to
;;;		tell chrome which app(webpage) to be open or focus on(if already open)
;;; 4)	also in the shortcut property enter 2 more parameter to 
;;;		1. 	specify which ChromeProfile2 folder to use for that shortcut (or else chrome will try to open the shortcut
;;;			with default chrome profile folder)
;;;			--user-data-dir="<ChromeProfile2Dir>"
;;;		2.	activate shortcut to be open in debugmode with parameter
;;;			--remote-debugging-port=9222
;;;			mention that 9222 is default chrome debug port
;;;		e.g the complete target property will be like
;;;		"C:\Program Files (x86)\Google\Chrome\Application\chrome_proxy.exe" --user-data-dir="D:\Download\Games\AHK Script\ChromeProfile2" --profile-directory="Profile 1" --app-id=kbclbippbgkfecccpgmdjbghcnoffpip --remote-debugging-port=9222  --remote-allow-origins=*
;;;	5) what and how the webpage is automated must be done case by case for each page like what element to interact with what to do blah blah...
FileCreateDir, ChromeProfile2
 --- OBSOLETED : 2021.03.26 -------- >>>
*/

;;; UPDATED 2021.03.26
;;; CHANGE => all app will now open in the same chrome window
;;; To use chrome connect to automate webpage
;;; 1)	the chrome must be open in debug mode
;;; 	because all chrome page open within the same ChromeProfile2 folder will be count as the same session
;;; 	This will not working if one of the page of that profile is already open with non-debug mode
;;; 	so, 
;;; 	*** better create new ChromeProfile2 folder only used for automate only
;;; 	which in this case will create a folder name ChromeProfile2 at the same ahk-script working-directory
;;; 2)  Create new chrome shortcut in taskbar target as sample below
;;; 	"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --user-data-dir="D:\Download\Games\AHK Script\ChromeProfile2" --profile-directory="Profile 1" --remote-debugging-port=9222 --remote-allow-origins=*
;;;     	- Path to chrome 
;;;				: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
;;;			- Folder to contain ChromeProfile2
;;;				: --user-data-dir="D:\Download\Games\AHK Script\ChromeProfile2"
;;;				=> ChromeProfile2 should be separate from the default daily usage one/ so better create new folder
;;;			- Profile name (which is the sub inside ChromeProfile2)
;;;				: --profile-directory="Profile 1"
;;;				=> This profile name is the one showing in the chrome UI
;;;			- specified debugger port to connect to chrome
;;;				: --remote-debugging-port=9222
;;;				=> 9222 is default chrome debug port
;;;			*** to make chrome use this new created ChromeProfile2 as profile folder, just run this shortcut once, the necessary file will be generated in this new ChromeProfile2 folder by chrome itself
;;; 3)	Add webpage to be automately used
;;;			-> within chrome from 2), goto webpage to be used
;;;			-> Use the app shortcut feature from chrome to create individual-like app for the page (w/o "open as window")
;;;	4)	Note the AppID for those newly created shortcut
;;;			-> can be done by temp create shortcut and goto its property, the appID will be the parameter in "target"
;;; 5)	use that appID in coding below
;;;	6)	what and how the webpage is automated must be done case by case for each page like what element to interact with what to do blah blah...

; create new ChromeProfile2 folder if not yet exist
DirCreate("ChromeProfile2")

appID_wani 		:= "--app-id=kbclbippbgkfecccpgmdjbghcnoffpip"
;appID_nozomi 	:= "--app-id=ongehjigacijoeffjphbihiogpjmjbje"
appID_nozomi 	:= "--app-id=kkeapbkegdegdjlgafdjeahhcdgphhbl"
appID_jisho 	:= "--app-id=bcmfklecpgmbcjepakakahjoppimeecc"
;appID_jtdic 	:= "--app-id=anhnclmdnngokbocfngdlffbhjjebdjk"
appID_longdo	:= "--app-id=ombpekmknciekcnefoenocjedpaiobdi"
appID_neocities := "--app-id=oaddegjdphhfmbfkmmhhlfagepepcchh"
appID_tangorin  := "--app-id=oefmokidiggjcbaambomlkgekphnocaf"
appID_tatoeba	:= "--app-id=hkcjcebednckodgoeeonmgmogjclapeb"
appID_bonten	:= "--app-id=mipdpgcoieonhpgflbnghgolipdhkmdh"
appID_nlb		:= "--app-id=ihnlaaefnoglfiibolonigmnlogmbapd"
appID_jtdic		:= "--app-id=cfbpkkfchjnjnoeakfhlkccponedggjp"

gv_chromeTaskbarPos := "3"

appID_kiseki	:= "--app-id=ccpiladofbgfdbcgbcccncnhigpbddkk"
appID_ys		:= "--app-id=fccaimmjlmpaifjelmiklmjlohfacnkb"


;**************************************************
;	F U N C T I O N S
;**************************************************
;-==

setBorderless(winTitle){
	
		WinSetStyle("^0xC00000", winTitle)  ; Remove borders
		WinSetStyle("^0x40000", winTitle)  ; Including the resize border
		;WinMove, % winTitle,,	0, 0, A_ScreenWidth, A_ScreenHeight
		;WinMove, % winTitle,,	50, 20, 1600, 900
	
		
	return

}

debugMsg( in_msg, in_type := "tooltip", in_time := 2000 ){
; msg type as
;	- tooltip
;   - msgbox

	global gv_debug

	if( gv_debug = 1 ){
		if( in_type = "tooltip" ){
			genToolTip( in_msg, in_time )
		}else if ( in_type = "msgbox" ){
			MsgBox(in_msg)
		}
	}
}

genToolTip( in_msg, in_time := 2000 ){
/*
	custom function to popup tooltip and hide in X second
*/
	; set time period to show message (in ms)
	lifetime := in_time * -1

	ToolTip(in_msg)
	SetTimer(RemoveToolTip,lifetime)
}

RemoveToolTip()
{
	ToolTip()
	return
}

;;genBackupInDir;;
genBackupInDir( in_backupDir ){

	; -- Prompt input filename from user with default name as script + current date
	; Generate backup filename with current date
	strArray := strSplit( A_ScriptName, "." )
	noExt := strArray[1]
	defaultFilename := noExt . "_" . A_YYYY . "" . A_MM . "" . A_DD . ".ahk"
	
	; display input box asking for filename
	; InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default]
	IB := InputBox("Please input backup file name", "Backup script file", "w300 h130", defaultFilename), filename := IB.Value, ErrorLevel := IB.Result="OK" ? 0 : IB.Result="CANCEL" ? 1 : IB.Result="Timeout" ? 2 : "ERROR"
	if ErrorLevel
		; user press cancel
		return

	; check if input backup directory is existed
	if not ( FileExist( in_backupDir ) = "D" ){ ; not exist or is not "D"irectory
		; Create directory in current script path with specified directory name
		DirCreate(in_backupDir)
	}
	
	
	backup_fullpath := in_backupDir . "\" . filename
	
	; check if input filename is already existed
	if ( FileExist( backup_fullpath ) ){
		; raise notice msg and restart backup process
		MsgBox("Filename " . filename . " is already existed. Please input new filename")
		genBackupInDir( in_backupDir )
	}
	
	; -- Begin backup current script
	; Copy script into specified directory
	Try{
	   FileCopy(A_ScriptName, backup_fullpath)
	   ErrorLevel := 0
	} Catch as Err {
	   ErrorLevel := Err.Extra
	}
	
	return
}

;--- Chrome automate ---;
;;; Search for existing chrome page with input url (startwith)
;;; If not found then create new Chrome instance which will open
;;; new chrome page with specified url/appID
;;; *** search by title is not working because title will be blanked for quite sometime during newly created
;;getCreatePageByURL;;
getCreatePageByURL( url, appID ){

	lo_chromeInst
	lo_pageInst := ""
	
	; first, try to check if any chrome with debug option is already open
	if( lo_chromeInst := Chrome.FindInstance() ){
	
		debugMsg("Chrome instance found : " . url, "msgbox")
	
		; search the opened page for the page with input url
		; if not found then lo_pageInst will be null
		lo_pageInst := lo_chromeInst.GetPageByURL(url, MatchMode:="startswith")
	}
	
	; the lo_pageInst null mean no page found with specified URL,
	; then open new chrome page with specified url
	if( !lo_pageInst ){
	
		debugMsg("lo_pageInst null", "msgbox")
		
		lo_chromeInst := Chrome(ProfilePath := "ChromeProfile2", Flags := appID )
		
		;msgbox, % "Chrome : " JSON.Stringify( go_chromeInst.GetPageList(), "`t" )
		
		; because the delay between the time when chromeInst create and the url show up in the list
		; use loop to wait until the specified url avaiable
		while ( !lo_pageInst ){
			lo_pageInst := lo_chromeInst.GetPageByURL(url, MatchMode:="startswith")
			Sleep(100)
		}
		
	}
	
	
	
	; wait for page to load,
	; (quite useless because the event fired eventhough the page not yet done loaded)
	lo_pageInst.WaitForLoad()
	
	;msgbox, % "page : " lo_pageInst.connected " ID : " lo_pageInst.ID
	
	;msgbox, % "Chrome : " JSON.Stringify( go_chromeInst.GetPageList(), "`t" )
	
	return lo_pageInst

}

; loop checking for the existence of input element on the page
; this use to ensure the element is loaded before interact with it
waitForElementLoad( page, elemId ){
;;;	page : page instanst which element is on
;;; elemId : element ID from document to be search for

	;test := page.Evaluate("document.getElementById('" . elemId . "')")
	;msgbox, % JSON.Stringify(test, "`t")
/*
	while ( page.Evaluate("$('#" . elemId . "')").subtype = "null" ){
		Sleep, 300
	} 
*/
	while ( page.Evaluate("document.getElementById('" . elemId . "')").subtype = "null" ){
		Sleep(300)
	} 
	
	;test := page.Evaluate("$('#" . elemId . "')")
	;msgbox, % JSON.Stringify(test, "`t")
	
	return

}

; call for chrome-wanikani app and auto input and search for text from the clipboard
wanikaniSearch(){

	global appID_wani

	; get existing wk page or start new one if not yet opened
	wkPage := getCreatePageByURL( "https://www.wanikani.com", appID_wani )
	
	;; match mode : startWith
	;SetTitleMatchMode, 1
	;WinActivate, WaniKani
	
	activateChromeTab( "WaniKani" )

	; check and wait if the text box for query word is not yet finished loading
	; waitForElementLoad(wkPage, "query")

/* BEG-DEL 2021.10.01 : change from js injection to direct url parameter query

	try{
		; create JS string for injection
		
		; scroll to the top of page
		js := "$('html, body').animate({ scrollTop: 0 }, 'fast');"
		result := wkPage.Evaluate(js)
		
		; display the search area (in case that it's not yet display)
		js := "$(""#search-bar"").removeClass(""hidden"");"
		result := wkPage.Evaluate(js)
		
		; input value from clipboard into query input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "$(""#query"").val( """ . Trim( searchText ) . """ );"
		result := wkPage.Evaluate(js)
		
		; submit form to begin searching
		js := "$(""#search-form"").submit()"
		result := wkPage.Evaluate(js)
		
		}catch as e{
		MsgBox, % "Exception encountered in " e.What ":`n`n"
		. e.Message "`n`n"
		. "Specifically:`n`n"
		. JSON.Stringify(JSON.parse(e.Extra), "`t")

	}
*/

;;; BEG-ADD 2021.10.01 : change from js injection to direct url parameter query 

	; ;https://www.wanikani.com/search?utf8=%E2%9C%93&query=<keyword>
	; input value from clipboard into input textbox
	; get text from clipboard and remove all new line and vertical tab
	searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
	navigate_url := "https://www.wanikani.com/search?utf8=%E2%9C%93&query=" . Trim( searchText )

	; navigate to url
	wkPage.Call( "Page.navigate", Map( "url", navigate_url ) )
	
;;; END-ADD 2021.10.01 : change from js injection to direct url parameter query 
	
	return

}

jishoSearch(){
	
	global appID_jisho
	
	; get existing jisho page or start new one if not yet opened
	jishoPage := getCreatePageByURL( "https://jisho.org/", appID_jisho )
	
	; Activate chrome window and activate specific tab

	activateChromeTab( "Jisho.org" )
	; check and wait if the input search to be loaded
	waitForElementLoad(jishoPage, "keyword")
	
	
	
	try{
	
		; create JS string for injection
		
		; scroll to the top of page
		js := "$('html, body').animate({ scrollTop: 0 }, 'fast');"
		result := jishoPage.Evaluate(js)
		
		; input value from clipboard into query input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "$('#keyword').val( '" . Trim( searchText ) . "' );"
		result := jishoPage.Evaluate(js)
		
		; submit form to begin searching
		js := "$('#search').submit()"
		result := jishoPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}
	
}

nozomiSearch(){

	global appID_nozomi
	
	; get existing jisho page or start new one if not yet opened
	;nozomiPage := getCreatePageByURL( "https://www.nozomi.ml/", appID_nozomi )
	nozomiPage := getCreatePageByURL( "https://nzmbot.herokuapp.com/", appID_nozomi )
	
	;; match mode : startWith
	;SetTitleMatchMode, 1
	;WinActivate, nozomibot
	
	activateChromeTab( "nozomibot" )
	; check and wait if the input search to be loaded
	waitForElementLoad(nozomiPage, "input_word")
	
	
	
	try{
	
		; create JS string for injection
		
		; scroll to the top of page
		js := "$('html, body').scrollTop(290);"
		result := nozomiPage.Evaluate(js)
		
		; input value from clipboard into query input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		;js := "$(""#input_word"").val( """ . Trim( searchText ) . """ );"
		js := "vue.word = '" . Trim( searchText ) . "';"
		result := nozomiPage.Evaluate(js)
		
		; submit form to begin searching
		js := "ajax_dict();"
		result := nozomiPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}

}

jtdicSearch(){

	global appID_jtdic

	; get existing jisho page or start new one if not yet opened
	jtdicPage := getCreatePageByURL( "http://www.jtdic.com/", appID_jtdic )
	
	debugMsg("Jtdic page Connected : " . jtdicPage.Connected, "msgbox")
	
	;; match mode : startWith
	;SetTitleMatchMode, 1
	;WinActivate, Online Japanese Thai
	
	activateChromeTab( "Online Japanese Thai" )
	
	debugMsg("Jtdic check loading", "msgbox")
	
	; check and wait if the input search to be loaded
	waitForElementLoad(jtdicPage, "txtSearch")
	
	debugMsg("JTdic load done", "msgbox")
	
	
	
	try{
	
		; create JS string for injection
		
		; input value from clipboard into query input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "document.getElementById('txtSearch').value = '" . Trim( searchText ) . "';"
		result := jtdicPage.Evaluate(js)
		
		; submit form to begin searching
		js := "document.getElementById('form1').submit();"
		result := jtdicPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}
	
	debugMsg("JTdic automated done", "msgbox")

}

longdoSearch(){

	global appID_longdo

	; get existing jisho page or start new one if not yet opened
	longdoPage := getCreatePageByURL( "https://dict.longdo.com", appID_longdo )
	
	debugMsg("Longdo page Connected : " . longdoPage.Connected, "msgbox")
	
	;; match mode : Contain
	;SetTitleMatchMode, 2
	;WinActivate, Longdo Dictionary
	
	activateChromeTab( "Longdo Dictionary" )
	
	debugMsg("Longdo check loading", "msgbox")
	
	; check and wait if the input search to be loaded
	waitForElementLoad(longdoPage, "search")
	
	debugMsg("Longdo load done", "msgbox")
	
	
	
	try{
		; command to automated search
		;$('#search').val('test');
		;$('#dict').submit();
	
		; create JS string for injection
		
		; input value from clipboard into input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "$('#search').val('" . Trim( searchText ) . "');"
		result := longdoPage.Evaluate(js)
		
		; submit form to begin searching
		js := "$('#dict').submit();"
		result := longdoPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}
	
	debugMsg("Longdo automated done", "msgbox")

}

neocitiesSearch(){

	global appID_neocities

	; get existing jisho page or start new one if not yet opened
	neocitiesPage := getCreatePageByURL( "https://sentencesearch.neocities.org", appID_neocities )
	
	debugMsg("neocities page Connected : " . neocitiesPage.Connected, "msgbox")
	
	;; match mode : Contain
	;SetTitleMatchMode, 2
	;WinActivate, Sentence Search
	
	activateChromeTab( "Sentence Search" )
	
	debugMsg("neocities check loading", "msgbox")
	
	; check and wait if the input search to be loaded
	waitForElementLoad(neocitiesPage, "searchInput")
	
	debugMsg("neocities load done", "msgbox")
	
	
	
	try{
		; command to automated search
		; $("#searchInput").val("test");
		; startSearch()
	
		; create JS string for injection
		
		; input value from clipboard into input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "$('#searchInput').val('" . Trim( searchText ) . "');"
		result := neocitiesPage.Evaluate(js)
		
		; submit form to begin searching
		js := "startSearch();"
		result := neocitiesPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}
	
	debugMsg("neocities automated done", "msgbox")

}

tangorinSearch(){

	global appID_tangorin

	; get existing jisho page or start new one if not yet opened
	tangorinPage := getCreatePageByURL( "https://tangorin.com", appID_tangorin )
	
	debugMsg("tangorin page Connected : " . tangorinPage.Connected, "msgbox")
	
	;; match mode : Contain
	;SetTitleMatchMode, 2
	;WinActivate, Tangorin
	
	activateChromeTab( "Tangorin" )
	
	; searching with tangorin is just calling endpoint with parameter
	
	; input value from clipboard into input textbox
	; get text from clipboard and remove all new line and vertical tab
	searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
	navigate_url := "https://tangorin.com/sentences?search=" . Trim( searchText )
	
	; navigate to url
	tangorinPage.Call("Page.navigate", Map( "url", navigate_url ))
	
	debugMsg("tangorin automated done", "msgbox")

}

;https://tatoeba.org/eng/sentences/search?query=ๆๅณ็&from=jpn&to=

tatoebaSearch(){

	global appID_tatoeba

	; get existing jisho page or start new one if not yet opened
	tatoebaPage := getCreatePageByURL( "https://tatoeba.org", appID_tatoeba )
	
	debugMsg("tatoeba page Connected : " . tatoebaPage.Connected, "msgbox")
	
	;; match mode : Contain
	;SetTitleMatchMode, 2
	;WinActivate, Tatoeba
	
	activateChromeTab( "Tatoeba" )
	
	; searching with tatoeba is just calling endpoint with parameter
	
	; input value from clipboard into input textbox
	; get text from clipboard and remove all new line and vertical tab
	searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
	navigate_url := "https://tatoeba.org/eng/sentences/search?query=" . "'" . Trim( searchText ) . "'" . "&from=jpn&to="
	
	
	
	; navigate to url
	tatoebaPage.Call("Page.navigate", Map( "url", navigate_url ))
	
	debugMsg("tatoeba automated done", "msgbox")

}



bontenSearch(){

	global appID_bonten

	; get existing jisho page or start new one if not yet opened
	bontenPage := getCreatePageByURL( "https://bonten.ninjal.ac.jp", appID_bonten )
	
	debugMsg("bonten page Connected : " . bontenPage.Connected, "msgbox")
	
	;; match mode : Contain
	;SetTitleMatchMode, 2
	;WinActivate, Sentence Search
	
	activateChromeTab( "(BCCWJ)" )
	
	debugMsg("bonten check loading", "msgbox")
	
	; check and wait if the input search to be loaded
	waitForElementLoad(bontenPage, "string_search_words")
	
	
	
	debugMsg("bonten load done", "msgbox")
	
	try{
		; command to automated search
		; $("#string_search_words").val("<val>")
		; $('input[name="commit"]').click()
	
		; create JS string for injection
		
		; input value from clipboard into input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "$('#string_search_words').val('" . Trim( searchText ) . "');"
		result := bontenPage.Evaluate(js)
		
		; submit form to begin searching
		js := "$('input[name=`"commit`"]').click()"
		result := bontenPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}
	
	debugMsg("bonten automated done", "msgbox")

}



nlbSearch(){

	global appID_nlb

	; get existing jisho page or start new one if not yet opened
	nlbPage := getCreatePageByURL( "https://nlb.ninjal.ac.jp", appID_nlb )
	
	debugMsg("nlb page Connected : " . nlbPage.Connected, "msgbox")
	
	;; match mode : Contain
	;SetTitleMatchMode, 2
	;WinActivate, Sentence Search
	
	activateChromeTab( "NINJAL-LWP" )
	
	debugMsg("nlb check loading", "msgbox")
	
	; check and wait if the input search to be loaded
	waitForElementLoad(nlbPage, "searchbox")
	
	debugMsg("nlb load done", "msgbox")
	
	
	
	try{
		; command to automated search
		; $('#searchbox').val('123')
		; $('#go').click()
	
		; create JS string for injection
		
		; input value from clipboard into input textbox
		; get text from clipboard and remove all new line and vertical tab
		searchText := StrReplace(StrReplace(StrReplace(A_Clipboard, "`n", ""), "`v", ""), "`r", "")
		js := "$('#searchbox').val('" . Trim( searchText ) . "');"
		result := nlbPage.Evaluate(js)
		
		; submit form to begin searching
		js := "$('#go').click()"
		result := nlbPage.Evaluate(js)
	
	}catch as e{
		MsgBox("Exception encountered in " e.What ":`n`n"		. e.Message "`n`n"		. "Specifically:`n`n"		. JSON.Stringify(JSON.parse(e.Extra), "`t"))

	}
	
	debugMsg("nlb automated done", "msgbox")
	
}

/*
	Check and call related function to search for vocab
	if the hotkey condition is met
	appFunc	: Function name to be called for searching 
			  if the condition met
*/
ctrlCCheck( appFunc ){

	; Keep the current pressing hotkey with "$^" trimmed
	pressedKey := StrReplace(A_ThisHotkey, "$^")
	
	debugMsg( "key pressed : " . pressedKey )
	
	; check if ^c have been press less than 1 sec before this 
	if (A_PriorHotKey = "~^c" AND A_TimeSincePriorHotkey < 1000){
		; call the related function to call chrome on specified app/webpage
		%appFunc%()
	}else{
		; if condition is not met then just make the hotkey passthrough
		Send("^{ " pressedKey " }")
	}
}

;;activateChromeTab;;
activateChromeTab( tabTitle ){

	focusChromeWindow()

	; set some delay so that WinGetTitle can work properly to get Chrome tab name
	Sleep(100)

	; find chrome tab which contain specified webpage title
	
	; first, if the page is newly opened, it will be focused on with unloaded tab
	; which have title consist of "Untitled" or no title at all
	; If this the case then just stay on this tab
	activatedTab := WinGetTitle("A")
	if ( InStr(activatedTab, "Untitled") != 0 or activatedTab = "" ){
		return
	}
	
	; find chrome tab which contain specified webpage title
	Loop 10
	{
	
		activatedTab := WinGetTitle("A")
		if ( InStr(activatedTab, tabTitle) != 0 )
			break
	
		Send("^{Tab}")
		Sleep(20)
		
	}
	return

}

focusChromeWindow(){

	global gv_chromeTaskbarPos

	; Switch to chrome window
	; the step is
	; 1) "win + t" to focus on taskbar
	; 2) "win + %pos%" to switch to specified window
	; **** if use win + %num% directly without win+t first, if window is already focused
	;      it will be minimized, which doesn't work
	
	; wait for user to release the ctrl key first, or else the following Win+t won't work properly
	while (GetKeyState("Ctrl", "P")){
		Sleep(100)
	}
	
	Send("#{ T }")
	Sleep(50)
	Send("#{ " gv_chromeTaskbarPos " }")
	
}

;;randomInput;;
randomInput( in_number, rand_range := 15 ){
	; generate random number from input within random range
	; e.g.
	; in_number = 50
	; rand_range = 10
	; return value between 40 - 60

	rand_min := rand_range * -1
	rand_max := rand_range

	rand := Random(rand_min, rand_max)
	
	return in_number + rand

}

sendText( in_text ){
	; Send whole text immediately
	SavedClip := ClipboardAll()
    A_Clipboard := in_text
    Send("^v")
    A_Clipboard := SavedClip
	return
}

getClientSize(hWnd, &w := "", &h := "")
{
	; ;hWnd : a unique ID return from function which get window e.g. WinGet(with subCommand ID)
	; VarSetStrCapacity(&rect, 16) ; V1toV2: if 'rect' is NOT a UTF-16 string, use 'rect := Buffer(16)'
	; DllCall("GetClientRect", "ptr", hWnd, "ptr", rect)
	; w := NumGet(rect, 8, "int")
	; h := NumGet(rect, 12, "int")

	WinGetClientPos ,,&w, &h, "ahk_id " hWnd

}

getWindowOwner( in_winTitle := "A" ){
	; in_winTitle = wintitle parameter refer : https://www.autohotkey.com/docs/v1/misc/WinTitle.htm

	vPID := WinGetPID(in_winTitle)
	for oProcess in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId = " vPID)
	{
		oProcess.GetOwner(&vOwner)
		return vOwner
	}
}

test( aaa, args* ){
	if( args.Length = 0 ){
		msgbox("no argument")
	}
	test2( aaa, args* )
}

test2( aaa, bbb := "5", ccc := "1" ){
	msgbox(aaa " : " bbb " / " ccc )
}

;==-

;**************************************************
;	I M P L E M E N T A T I O N
;**************************************************
;-==

; SetKeyDelay [, Delay, PressDuration, Play]
SetKeyDelay(40, 40)
SetMouseDelay(70)

; Use client as coordmode
CoordMode("Mouse", "Client")

; Add new rule for grouping all Nino kuni client windows
GroupAdd("nnk", zWinTitle)

;test( 1 )

;fntest := test2.Bind( "1",, "3" )
;fntest()
;==-

;**************************************************
;	R U N T I M E - H O T K E Y
;**************************************************
return

;**************************************************
;	H O T K E Y
;**************************************************

;======================================================
;	-- N I  N O   K U N I   C R O S S   W O R L D S --
;================================================== -==
;-++

; hotkey for netmarble launcher
#HotIf WinActive("ahk_exe Netmarble Launcher.exe")

; Display user that run current launcher and set the title
F1::
	; Get user that run current window PID
{ ; V1toV2: Added bracket
	owner := getWindowOwner()
	genToolTip(owner)
	userno := username_map[owner]
	
	WinSetTitle("NetmarbleLauncher " userno)
} ; V1toV2: Added Bracket before hotkey or Hotstring

; set title according to process owner
F2::
{ ; V1toV2: Added bracket
	owindowList := WinGetList("ahk_exe Netmarble Launcher.exe",,,)
	awindowList := Array()
	windowList := owindowList.Length
	For v in owindowList
	{   awindowList.Push(v)
	}
	Loop awindowList.Length
	{
		thisWindowID := awindowList[A_Index]
		
		owner := getWindowOwner( "ahk_id " thisWindowID )
		
		userno := username_map[owner]
		
		WinSetTitle(userno, "ahk_id " thisWindowID)
	}
	genToolTip("done")
	
} ; V1toV2: Added bracket in the end

#HotIf WinActive( "ahk_exe ProjectN-Win64-Shipping.exe" )



;Change weapon
F1::nino_altCombine(1)
F2::nino_altCombine(2)
F3::nino_altCombine(3)

; hatching
F4::

{ ; V1toV2: Added bracket
		; open menu
	Send("{F10}")
	
	Sleep(100)
	
	; click Familiars menu
	nino_click_ratio( 3.5, 50, 1 ,1 )
	Sleep(350)
	; click Hatch menu
	nino_click_ratio( 10.5, 50, 0, 0 )
} ; V1toV2: Added Bracket before hotkey or Hotstring

; open menu
F5::F10
; world map
F6::
{ ; V1toV2: Added bracket
	SetKeyDelay(-1, 200)
	nino_ctrlCombine( "m" )
} ; V1toV2: Added Bracket before hotkey or Hotstring

; Fam adventure

F7::
{ ; V1toV2: Added bracket
	; open menu
	Send("{F10}")
	
	Sleep(100)
	
	; click Challenge
	nino_click_ratio( 96.614583, 49.256690, 1 ,1 )
	Sleep(350)
	; click FamAdv
	nino_click_ratio( 90.208333, 53.617443, 1, 1 )
} ; V1toV2: Added Bracket before hotkey or Hotstring

; Hibernate mode
F8::
	; open menu
{ ; V1toV2: Added bracket
	Send("{F10}")
	
	Sleep(100)
	nino_click_ratio( 51.614583, 94.945491, 1 ,1 )
	
	Sleep(100)
	WinMinimize("A")
}

; to prevent accidentally open Deck (Ctrl+d) while moving and change Imagen(ctrl+1/2/3)
; tweak how key "d" work by adding Ctrl Up before trigger key d
d::
{
	Send "{Ctrl Up}{d down}"
	KeyWait("d")
	Send "{d Up}"
}

; Change Imagen
xbutton2::nino_ctrlCombine(1)
xbutton1::nino_ctrlCombine(2)
mbutton::nino_ctrlCombine(3)
^xbutton1::nino_ctrlCombine(3)



!q::
{
	;spam click at mouse position (with random offset)

	global FnObj_spamClick

	; get current mouse position
	MouseGetPos(&muse_xpos, &muse_ypos)

	; generate the function obj with parameter and keep in global variable for later use when delete the timer
	FnObj_spamClick := nino_spamClick.Bind( muse_xpos, muse_ypos )
	
	SetTimer( FnObj_spamClick ,20)

} ; V1toV2: Added Bracket before hotkey or Hotstring

!w::
{ ; V1toV2: Added bracket
	; stop the spam click from !q hotkey
	global FnObj_spamClick
	SetTimer( FnObj_spamClick , 0)
return
}

!t::
{
	startSpamFnToCurrentCtrl( "nino_catch_cluu", 20, true )	
}

nino_catch_cluu(hWnd){
	;SetMouseDelay(1)
	;MsgBox(A_MouseDelayPlay)
	;MsgBox(A_MouseDelay)
	nino_click_ratio( 40.625, 45.094152626362735 )
	Sleep(1)
	nino_click_ratio( 47.760416666666664, 45.490584737363726 )
	Sleep(1)
	nino_click_ratio( 55.052083333333336, 45.589692765113973 )
	Sleep(1)
	nino_click_ratio( 39.895833333333336, 55.10406342913776 )
	Sleep(1)
	nino_click_ratio( 47.395833333333329, 55.599603567888998 )
	Sleep(1)
	nino_click_ratio( 55.364583333333329, 55.500495540138751 )
	Sleep(1)
	nino_click_ratio( 39.375, 66.204162537165516 )
	Sleep(1)
	nino_click_ratio( 47.552083333333336, 66.600594648166506 )
	Sleep(1)
	nino_click_ratio( 55.833333333333336, 66.699702675916754 )

}

; spam burst skill (of 3rd slot weapon)
!s::
{ ; V1toV2: Added bracket
	genToolTip( "on" )
	startSpamFnToCurrentCtrl( "nino_burst", 7000, true )	
} ; V1toV2: Added Bracket before hotkey or Hotstring

; stop the burst skill spam timer of current active nino window

; !d::
; { ; V1toV2: Added bracket
; 	genToolTip( "off" )
; 	stopSpamFnToCurrentCtrl( "nino_burst" )
; } ; V1toV2: Added Bracket before hotkey or Hotstring

; ai mode with recent location
!a::
{ ; V1toV2: Added bracket

	; first, check if the hotkey is used in the 4th nino window which suppose to be region NA and got quite a huge ping
	wintitle4 := nino_windows.Has(4) ? "ahk_id " nino_windows[4] : "CrossWorlds 4"
	if( winExist(wintitle4) ){
		delay := 500
	}else{
		delay := 0
	}

	if( isWinNormalRatio() ){
		; open menu
		Send("{F10}")
		Sleep(50)
		; click at AI mode button (1030,1030)
		nino_click_ratio( 54.384134, 94.722222, 0.1, 0.1 )
		Sleep(250)
		Sleep(delay)
		; click "AI in recent area" button (1400,1030)
		nino_click_ratio( 73.593750, 95.092593, 4, 1 )
		Sleep(250)
		; click "fast travel" button 950, 670
		nino_click_ratio( 49.895833, 62.037037, 4, 1.2 )
		Sleep(250)
	}else{
		; open menu
		Send("{F10}")
		Sleep(50)
		; click at AI mode button (1030,1030)
		nino_click( 530, 968, 3, 3 )
		Sleep(250)
		Sleep(delay)
		; click "AI in recent area" button (1400,1030)
		nino_click( 702, 969, 20, 4 )
		Sleep(250)
		; click "fast travel" button 950, 670
		nino_click( 472, 570, 20, 4 )
		Sleep(250)
	}
} ; V1toV2: Added Bracket before hotkey or Hotstring


; spam imagen first slot
!e::
{ ; V1toV2: Added bracket
	startSpamFnToCurrentCtrl("nino_imagen", 7000, 1, true)
} ; V1toV2: Added Bracket before hotkey or Hotstring

; !r::
; { ; V1toV2: Added bracket
; 	stopSpamFnToCurrentCtrl("nino_imagen")
; } ; V1toV2: Added Bracket before hotkey or Hotstring

; toggle on/off spam f button to control
!f::
{
	; check if spam is already activated?
	startSpamFnToCurrentCtrl("nino_spamF", 100, true)
}

; craft for sub-char
!g::
{ ; V1toV2: Added bracket
	SetMouseDelay(120)
	SetKeyDelay(200)
	
	; first, check if the hotkey is used in the 4th nino window which suppose to be region NA and got quite a huge ping
	hWnd4 := nino_windows[4]
	hWnd5 := nino_windows[5]
	if( winActive("ahk_id " hWnd4 ) || winActive("ahk_id " hWnd5 ) ){
		delay := 500
	}else{
		delay := 0
	}
	
	Send("{f}")
	
	; click Craft Weapon & Armor
	nino_click_ratio( 85.468750, 47.373637, 0, 0 )
	
	Sleep(delay)
	; click |< the least crafting amount
	nino_click_ratio( 72.708333, 84.440040, 0, 0 )
	
	; click craft
	nino_click_ratio( 86.927083, 94.053518, 0, 0 )
	; click confirm
	nino_click_ratio( 54.791667, 65.708622, 0, 0 )
	Sleep(delay)
	Sleep(100)
	; press esc
	Send("{ESC}")
	Sleep(300)
	; change to armor
	nino_click_ratio( 91.927083, 11.000991, 0, 0 )
	; click amount
	nino_click_ratio( 84.583333, 79.187314, 0, 0 )
	; click 5
	nino_click_ratio( 46.822917, 50.247770, 0, 0 )
	; click 9
	nino_click_ratio( 52.604167, 43.904856, 0, 0 )
	; click confirm
	nino_click_ratio( 55.416667, 73.934589, 0, 0 )
	Sleep(400)
	; click craft
	nino_click_ratio( 86.927083, 94.053518, 0, 0 )
	Sleep(delay)
	Sleep(100)
	; press esc
	Send("{ESC}")
	Sleep(delay)
	; press esc
	Send("{ESC}")
	Sleep(300)
	; click weapon
	nino_click_ratio( 77.395833, 11.496531, 0, 0 )
	; click |< the least crafting amount
	nino_click_ratio( 72.708333, 84.440040, 0, 0 )
	; click craft
	nino_click_ratio( 86.927083, 94.053518, 0, 0 )
	; click confirm
	nino_click_ratio( 54.791667, 65.708622, 0, 0 )
	Sleep(100)
	Sleep(delay)
	; press esc
	Send("{ESC}")
	Sleep(100)
	Send("!{F4}")
	Sleep(300)
	; click Select character
	nino_click_ratio( 49.895833, 69.970268, 0, 0 )
	
	Sleep(2300)
	; click Start Adventure
	nino_click_ratio( 88.489583, 94.449950, 0, 0 )

} ; V1toV2: Added Bracket before hotkey or Hotstring


; craft for main with weapon focused
!h::
; craft for main with armor focused
!j::
{ ; V1toV2: Added bracket

	delay := 0

	SetMouseDelay(120)
	SetKeyDelay(200)
	
	; first, check if the hotkey is used in the 4th nino window which suppose to be region NA and got quite a huge ping
	hWnd4 := nino_windows[4]
	hWnd5 := nino_windows[5]
	if( winActive("ahk_id " hWnd4 ) || winActive("ahk_id " hWnd5 ) ){
		delay := 500
	}else{
		delay := 0
	}
	
	Send("{f}")
	
	; click Craft Weapon & Armor
	nino_click_ratio( 85.468750, 47.373637, 0, 0 )
	
	Sleep(delay)
	
	; if focus armor then change to armor tab
	if( A_THISHOTKEY == "!j" ){
		Sleep(200)
		; change to armor
		nino_click_ratio( 91.927083, 11.000991, 0, 0 )
	}
	
	; default at weapon craft with amount max (100)
	; click craft
	Sleep(200)
	nino_click_ratio( 86.927083, 94.053518, 0, 0 )
	Sleep(delay)
	Sleep(200)
	; press esc
	Send("{ESC}")
	Sleep(delay)
	Sleep(100)
	; press esc
	Send("{ESC}")
	Sleep(100)
	
	Send("{ESC}")
	Sleep(300)
	
	; if focus armor case, then after craft armor, switch back to weapon for another 39 craft
	if( A_THISHOTKEY == "!j" ){
		; change to weapon
		nino_click_ratio( 77.395833, 11.496531, 0, 0 )
	}
	
	; craft another 39 weapon
	; click amount
	nino_click_ratio( 84.583333, 79.187314, 0, 0 )
	; click 5
	nino_click_ratio( 52.708333, 56.590684, 0, 0 )
	; click 9
	nino_click_ratio( 52.604167, 43.904856, 0, 0 )
	; click confirm
	nino_click_ratio( 55.416667, 73.934589, 0, 0 )
	Sleep(400)
	; click craft
	nino_click_ratio( 86.927083, 94.053518, 0, 0 )
	; click confirm
	nino_click_ratio( 54.791667, 65.708622, 0, 0 )
	Sleep(delay)
	Sleep(100)
	; press esc
	Send("{ESC}")
	Sleep(100)
	Send("!{F4}")
	Sleep(300)
	; click Select character
	nino_click_ratio( 49.895833, 69.970268, 0, 0 )
	
	
	Sleep(2300)
	
	; change this value to define class to switch to
	l_class := "1"
	switch l_class
		{
		Case "1":
			; select rogue
			nino_click_ratio( 4.270833, 29.534192, 0, 0 )
		Case "2":
			; select destro
			nino_click_ratio( 3.177083, 39.444995, 0, 0 )
		Case "3":
			; select witch
			nino_click_ratio( 3.072917, 49.157582, 0, 0 )
		Case "4":
			; select engy
			nino_click_ratio( 3.125000, 59.068385, 0, 0 )
		Case "5":
			; select swordman
			nino_click_ratio( 2.864583, 67.988107, 0, 0 )
	}
	Sleep(100)
	; click Start Adventure
	nino_click_ratio( 88.489583, 94.449950, 0, 0 )
	
} ; Added bracket before function

nino_spamF(in_control){
	global WM_KEYDOWN
	global WM_KEYUP
	ErrorLevel := SendMessage(WM_KEYDOWN, 0x46, 0, , "ahk_id " in_control)
	ErrorLevel := SendMessage(WM_KEYUP, 0x46, 0xC0000000, , "ahk_id " in_control)

}

; change deck
!1::
!2::
!3::
!4::
!5::
!6::
!7::
!Numpad6::
!Numpad7::
;!d::
{ ; V1toV2: Added bracket
	debugMsg("Changing Deck")
	
	; first, keep the current mouse position
	MouseGetPos(&curr_x, &curr_y)
	
	if( isWinNormalRatio() ){
	
		; click deck button at the bottom right 
		nino_click_ratio( 98.44, 96.67, 0.25, 0.5 )
		Sleep(300)
		; select the deck according to the input hotkey
		switch A_ThisHotkey
		{
		Case "!1":
			nino_click_ratio( 90.677083, 52.527255, 2.5, 1 )
		Case "!2":
			nino_click_ratio( 90.937500, 58.870168, 2.5, 1 )
		Case "!3":
			nino_click_ratio( 89.947917, 65.609514, 2.5, 1 )
		Case "!4":
			nino_click_ratio( 90.260417, 71.674074, 2.5, 1 )
		Case "!5":	
			nino_click_ratio( 90.208333, 78.677778, 2.5, 1 )
		Case "!6":	
			nino_click_ratio( 89.687500, 84.651852, 2.5, 1 )
		Case "!Numpad6":
			nino_click_ratio( 89.687500, 84.651852, 2.5, 1 )
		Case "!Numpad7":
			nino_click_ratio( 90.104167, 91.648148, 2.5, 1 )
		Case "!7":	
			nino_click_ratio( 90.104167, 91.648148, 2.5, 1 )
		}
	
	}else{ ; if not normal ratio then suppose its a half screen width with full height from snap mode
		; click deck button at the bottom right 
		nino_click( 942, 980, 5, 5 )
		Sleep(300)
		; select the deck according to the input hotkey
		switch A_ThisHotkey
		{
		case "!1":
			nino_click( 862, 728, 50, 10 )
		Case "!2":
			nino_click( 859, 764, 50, 10 )
		Case "!3":
			nino_click( 867, 800, 50, 10 )
		Case "!4":
			nino_click( 871, 836, 50, 10 )
		Case "!5":	
			nino_click( 861, 872, 50, 10 )
		Case "!6":	
			nino_click( 867, 908, 50, 10 )
		Case "!7":	
			nino_click( 853, 944, 50, 10 )
		}
	}
	Sleep(100)
	; Move mouse back to the position before hotkey
	MouseMove(curr_x, curr_y, 0)
	
} ; V1toV2: Added Bracket before hotkey or Hotstring

/*
; macro teleport to current map's boss
} ; V1toV2: Added Bracket before hotkey or Hotstring
!b::

	; first, check if the hotkey is used in the 4th nino window which suppose to be region NA and got quite a huge ping
{ ; V1toV2: Added bracket
	hWnd := nino_windows[4]
	if( winActive("ahk_id " hWnd ) ){
		delay := 1000
	}else{
		delay := 0
	}

	if( isWinNormalRatio() ){
	
		; open map
		Send, m
		sleep, %delay%
		; change tab
		nino_click_ratio( 68.958333, 30.925926, 0.25, 0.5 )
		; click on boss
		nino_click_ratio( 65.677083, 39.722222, 0.25, 0.5 )
		; click move
		nino_click_ratio( 71.145833, 38.796296, 0.25, 0.5 )
		; click teleport
		nino_click_ratio( 57.656250, 62.222222, 2.5 ,1 )
		
		nino_click_ratio( 42.08, 61.94, 5, 2 )
	
	}else{ ; suppose half screen width from snap mode
	
		; open map
		Send, m
		sleep, %delay%
		
		; change tab
		nino_click( 669, 392, 5, 5 )
		; click on boss
		nino_click( 628, 435, 5, 5 )
		; click move
		nino_click( 693, 433, 5, 5 )
		; click teleport
		nino_click( 551, 570, 50 ,10 )
		
		nino_click( 396, 569, 50, 10 )
		
	}

return
*/


;;;auto key user
;#z::
;#x::
;#c::
;#v::
;#b::

#/::
{ ; V1toV2: Added bracket
	switch SubStr(A_ThisHotkey, -1)
		{
		case "z":
			owner := "m-local"
		Case "x":
			owner := "nino2"
		Case "c":
			owner := "nino3"
		Case "v":
			owner := "nino4"
		Case "b":	
			owner := "nino5"
		Case "/":
			; get owner of current window
			owner := getWindowOwner()
		}

	; derive user/pw from defined list
	user := userlist[owner][1]
	pw := userlist[owner][2]

	SendMode("Event")
	
	SetKeyDelay 30, 30
	Send("^a")
	SendInput("{text}" user)
	Sleep(30)
	Send("{Tab}")
	Send("^a")
	SendInput("{text}" pw)
	Sleep(50)

} ; V1toV2: Added Bracket before hotkey or Hotstring

^#/::
{ ; V1toV2: Added bracket
	SendLevel 1
	Loop 4 {
		if( hWnd := WinExist("CrossWorlds " A_Index ) ){
			WinActivate( "ahk_id " hWnd )
			SendEvent "#{/}"
		}
	}
	
return
} ; V1toV2: Added Bracket before hotkey or Hotstring


; set all open nino windows title and save hWnd
^#Numpad0::{ ; V1toV2: Added bracket
	; get all hWnd/unique id of all NNK windows
	owindowList := WinGetList("ahk_group nnk",,,)
	awindowList := Array()
	windowList := owindowList.Length
	For v in owindowList{   
		awindowList.Push(v)
	}
	; above Winget return value in windowList
	;	- windowList itself contain number of retrieved windows
	;	- windowList1, windowList2, ...., windowListN : contain unique ID of each window found

	Loop awindowList.Length
	{
		hWnd := awindowList[A_Index]
		
		; set window title according to the owner user for window
		owner := getWindowOwner( "ahk_id " hWnd )
		userno := username_map[owner]
		
		WinSetTitle("CrossWorlds " userno, "ahk_id " hWnd)
		
		; keep hWnd for each window in array for later use
		nino_windows[userno] := hWnd
	}
	genToolTip( "Done" )
} ; V1toV2: Added Bracket before hotkey or Hotstring

; Set window title by the window owner
^#NumpadDot::
{ ; V1toV2: Added bracket
	hWnd := WinGetID()
	
	; set window title according to the owner user for window
	owner := getWindowOwner( "ahk_id " hWnd )
	userno := username_map[owner]
	
	WinSetTitle("CrossWorlds " userno, "ahk_id " hWnd)
	
	; keep hWnd for each window in array for later use
	nino_windows[userno] := hWnd
		
} ; V1toV2: Added Bracket before hotkey or Hotstring

/*
; save window by run username
} ; V1toV2: Added Bracket before hotkey or Hotstring
^#Numpad1::
^#Numpad2::
^#Numpad3::
^#Numpad4::
^#Numpad5::
	; get hWnd/unique id of current active window
{ ; V1toV2: Added bracket
	hWnd := WinExist("A")
	; use last string of input hotkey and as a key for array
	key := SubStr(A_ThisHotkey, 0)
	; keep hWnd for each window in array for later use
	nino_windows[key] := hWnd
	; change window title
	WinSetTitle, CrossWorlds %key%
return
*/

; change potion

#`::
#1::
#2::
#3::
	;16.562500, 3.567889
	; click and hold at potion icon for 1 sec
{ ; V1toV2: Added bracket
	nino_click_ratio( 15.562500, 3.567889, 0, 0, 500 )
	
	switch A_ThisHotkey
	{
		Case "#1":
			nino_click_ratio( 19.208333, 12.983152, 0, 0 )
		Case "#2":
			nino_click_ratio( 22.072917, 12.983152, 0, 0 )
		Case "#3":
			nino_click_ratio( 25.000000, 12.983152, 0, 0 )
	}
		
} ; V1toV2: Added Bracket before hotkey or Hotstring

; Register all non-minimized NNK windows for copy click / action
; Assumming that, all window arrange to be the same size ( snap to 
^#z::{ ; V1toV2: Added bracket
	global nino_copy_win_pos := map()

	; Get and loop through all NNK window
	owindowList := WinGetList("ahk_group nnk",,,)
	awindowList := Array()
	windowList := owindowList.Length
	For v in owindowList
	{   awindowList.Push(v)
	}

	Loop awindowList.Length
	{
		thisWindow := awindowList[A_Index]
		thisWindowMinMax := WinGetMinMax("ahk_id " thisWindow)
		; only do copy click on window that not minimized
		if ( thisWindowMinMax = 0 || thisWindowMinMax = 1 ) ; if the window is not minimized (can be maximized)
		{
			WinGetPos(&outX, &outY, , , "ahk_id " thisWindow)
			; Keep the position of window for later use
			nino_copy_win_pos[thisWindow] := [outX, outY]
		}
	}
	
	genToolTip( "" nino_copy_win_pos.Count " windows registered" )

}

^LButton::{

	CoordMode("Mouse", "Screen")
	; get the mouse position
	MouseGetPos(&outX, &outY)
	global copy_click_pos := [ outX, outY ]
}

^LButton up::{
	; to use this, use ^#z first to register all activated NNK window and its position
	; the position of these windows must remain the same while using this hotkey or else,
	; ^#z must be activate again to re-register the window position

	; need to use onClick UP instead, or else the blockinput will make Left click stuck at Down state after process done

	; Since WinActivate take alot of time to process
	; just use mouse to move around and click on position relate to screen instead of using WinActivate to improve speed

	SendMode("Event")

	Send("{Ctrl Up}")

	if( !nino_copy_win_pos.Count ){
		genToolTip( "X Register windows first" )
		return
	}

	SetMouseDelay(-1)
	CoordMode("Mouse", "Screen")

	; just in case the clicked window is not yet activated, then get the window under mouse cursor and activate it
	; Get the window under the mouse cursor (firstWin is Unique ID)
	MouseGetPos(, , &firstWin)

	if(!nino_copy_win_pos.Has(firstWin)){
		genToolTip("This window is not registered")
		return
	}

	; get the mouse left button release position
	MouseGetPos(&outX, &outY)

	; Determine if it's a click or drag

	; calculate distance (triangle) - c**2 = a**2 + b**2
	move_distance := Sqrt((copy_click_pos[1] - outX)**2 + ( copy_click_pos[2] - outY )**2)

	if(move_distance > 70){	; drag mode

		; block user input (esp. mouse move) during process to prevent misclick position if user move mouse
		;BlockInput("On")

		; ; first do the drag on current window
		; ; click and hold on starter position
		; MouseClick("L", copy_click_pos[1], copy_click_pos[2],,0,"D")
		; ; move mouse to destination pos and release
		; MouseClick("L", outX, outY, 1, 20, "U")

		; calculate the position of mouse for current window by offset
		; get the position of clicked window to calculate the offset (the win_pos will be array with coordinate [x,y]
		firstwin_pos := nino_copy_win_pos[firstWin]
		; ; offset is distance from top-left of window to mouse position
		; start_x := copy_click_pos[1] - firstwin_pos[1]
		; start_y := copy_click_pos[2] - firstwin_pos[2]
		; end_x := outX - firstwin_pos[1]
		; end_y := outY - firstwin_pos[2]

		SetMouseDelay(1)

		For Hwnd, win_pos_v in nino_copy_win_pos
		{
			; ; if it's the first clicked window then skip
			; if( hWnd == firstWin )
			; 	continue

			start_x := copy_click_pos[1] + (win_pos_v[1] - firstwin_pos[1])
			start_y := copy_click_pos[2] + (win_pos_v[2] - firstwin_pos[2])

			end_x := outX + (win_pos_v[1] - firstwin_pos[1])
			end_y := outY + (win_pos_v[2] - firstwin_pos[2])

			offset_x := end_x - start_x
			offset_y := end_y - start_y

			;MsgBox( "start : " start_x ", " start_y "`nend : " end_x ", " end_y )
			MouseMove(start_x,start_y,0)
			MouseClick("L",,,,0,"D")
			Sleep(50)
			; need to use high speed and divide movement into segment
			; !!! both speed in MouseMove command and SetMouseDelay effect the speed of mouse movement
			; so that the mouse is not too slow before release and not too fast that the game can't catch the mouse movement
			MouseMove(start_x + Floor(offset_x*0.2),start_y + Floor(offset_y*0.2), 1)
			MouseMove(start_x + Floor(offset_x*0.4),start_y + Floor(offset_y*0.4), 1)
			MouseMove(start_x + Floor(offset_x*0.6),start_y + Floor(offset_y*0.6), 1)
			MouseMove(start_x + Floor(offset_x*0.8),start_y + Floor(offset_y*0.8), 1)
			MouseClick("L",,,,0,"U")
			MouseMove(end_x, end_y, 3)
			;MouseClickDrag("L", start_x, start_y, end_x, end_y, 5)

			; Sleep(20)
			
		}

	}else{ ; click mode

		; block user input (esp. mouse move) during process to prevent misclick position if user move mouse
		BlockInput("On")
		
		; first, click on the current window
		MouseClick("L")

		; get the position of clicked window to calculate the offset (the win_pos will be array with coordinate [x,y]
		firstwin_pos := nino_copy_win_pos[firstWin]
		
		For hWnd, win_pos_v in nino_copy_win_pos
		{
			; if it's the first clicked window then skip
			if( hWnd == firstWin )
				continue

			Sleep(50)
			; calculate click position for each window by comparing position of current window with first window
			; and add the offset to the mouse position x,y
			click_x := outX + (win_pos_v[1] - firstwin_pos[1])
			click_y := outY + (win_pos_v[2] - firstwin_pos[2])
			MouseClick("L", click_x, click_y, 1, 0)
			
		}

	}
	
	
	
	Sleep(50)
	; move the mouse back to the original window
	MouseMove(outX, outY, 0)

	BlockInput("Off")
	
} ; V1toV2: Added Bracket before hotkey or Hotstring


; press ESC on registered (^#z) nnk windows
!Esc::{ ; V1toV2: Added bracket

	if( !nino_copy_win_pos.Count ){
		genToolTip( "X Register windows first" )
		return
	}

	CoordMode("Mouse", "Screen")

	SetKeyDelay(5)
	SetMouseDelay(20)
	
	MouseGetPos(&origin_X, &origin_Y)
	
	For hWnd, win_pos_v in nino_copy_win_pos
	{
		; position of each window title bar
		click_x := win_pos_v[1] + 200
		click_y := win_pos_v[2] + 15
		; click on title bar to activate window (this will make it much more faster than using winActivate)
		MouseClick("L", click_x, click_y, 1, 0)
		
		Send("{Esc}")
	}
	
	MouseMove(origin_X, origin_Y, 0)
} ; V1toV2: Added Bracket before hotkey or Hotstring

!l::{ ; V1toV2: Added bracket

	if( !nino_copy_win_pos.Count ){
		genToolTip( "X Register windows first" )
		return
	}

	CoordMode("Mouse", "Screen")

	SetKeyDelay(5)
	SetMouseDelay(20)
	
	MouseGetPos(&origin_X, &origin_Y)
	
	For hWnd, win_pos_v in nino_copy_win_pos
	{
		; position of each window title bar
		click_x := win_pos_v[1] + 200
		click_y := win_pos_v[2] + 15
		; click on title bar to activate window (this will make it much more faster than using winActivate)
		MouseClick("L", click_x, click_y, 1, 0)
		
		Send("{l}")
	}
	
	MouseMove(origin_X, origin_Y, 0)
}

; ; hotkey for running quest
; NumpadSub::
; NumpadMult::
; NumpadDiv::
; { ; V1toV2: Added bracket
; 	SetMouseDelay(10)

; 	loop_path := [7,5,6,8]
	
; 	For k, v in loop_path
; 	{
; 		nnk_no := A_Index + 4
; 		WinActivate("CrossWorlds " v)
; 		switch A_ThisHotkey
; 		{
; 			Case "NumpadSub":
; 				; select rogue
; 				nino_click_ratio( 68.684760, 76.239669, 1, 1 )
; 			Case "NumpadMult":
; 				; select destro
; 				nino_click_ratio( 88.100209, 95.454545, 1, 1 )
; 			Case "NumpadDiv":
; 				nino_click_ratio( 84.342380, 78.512397, 1, 1 )
				
; 		}
; 	}
	
; } ; V1toV2: Added Bracket before hotkey or Hotstring

; rapidly spam key/click (can be used to immediately skip dialogue)
^RButton::
{ ; V1toV2: Added bracket
	SetMouseDelay(0)
	SetKeyDelay(0, 0)
	
	while( GetKeyState( "LCtrl" ) ){
	
		Send("{LButton}")
		Send("{RButton}")
		Send("{Space}")
		if(A_Index == 20){
			break
		}
	}
} ; V1toV2: Added Bracket before hotkey or Hotstring

; hibernate all NNK window
!F8::
{ ; V1toV2: Added bracket
	SetKeyDelay(10)
	
	; Get and loop through all NNK window
	owindowList := WinGetList("ahk_group nnk",,,)
	awindowList := Array()
	windowList := owindowList.Length
	For v in owindowList
	{   awindowList.Push(v)
	}

	Loop awindowList.Length
	{
		thisWindow := awindowList[A_Index]
		thisWindowMinMax := WinGetMinMax("ahk_id " thisWindow)
		; only do copy click on window that not minimized
		if ( thisWindowMinMax = 0 || thisWindowMinMax = 1 ) ; if the window is not minimized (can be maximized)
		{
			WinActivate("ahk_id " thisWindow)
				; open meny
			Send("{F10}")
			
			Sleep(100)
			nino_click_ratio( 51.614583, 94.945491, 1 ,1 )
		}
	}
	
} ; V1toV2: Added Bracket before hotkey or Hotstring

^F4::WinClose()

F9::
{ ; V1toV2: Added bracket
	;in_control := ControlGetHwnd()
	; LAlt = 0xA4
	; SendMessage, <command type>, <key to be send>, <lparam>,, wintitle
	; use spy++ to check for value
	; post message pattern copy from the result of Spy++
	
	;SendMessage, %WM_KEYDOWN%, 0x11, 0x01000000,, ahk_id %in_control%
	;SendMessage, %WM_KEYDOWN%, 0x31, 0,, ahk_id %in_control%
	;SendMessage, %WM_KEYUP%, 0x31, 0xC0000000,, ahk_id %in_control%
	;SendMessage, %WM_KEYUP%, 0x11, 0xC1000000,, ahk_id %in_control%
	
	;SendMessage, %WM_KEYDOWN%, 0x25, 0,, ahk_id %in_control%		; keydown, 3
	;SendMessage, %WM_KEYUP%, 0x25, 0xC0000000,, ahk_id %in_control%	; keyup, 3
	;SendMessage, %WM_KEYDOWN%, 0x27, 0,, ahk_id %in_control%		; keydown, 3
	;SendMessage, %WM_KEYUP%, 0x27, 0xC0000000,, ahk_id %in_control%	; keyup, 3

	;SendMessage, %WM_KEYDOWN%, 0x12, 0x01000000,, ahk_id %in_control%	; keydown, alt
	;sleep, 7
	;SendMessage, %WM_KEYDOWN%, 0x33, 0,, ahk_id %in_control%		; keydown, 3
	;SendMessage, %WM_KEYUP%, 0x33, 0xC0000000,, ahk_id %in_control%	; keyup, 3
	;sleep, 7
	;SendMessage, %WM_KEYUP%, 0x12, 0xC1000000,, ahk_id %in_control%	; keyup, alt
	
	;PostMessage, %WM_SYSKEYDOWN%, 0x12, 0x01380001,, ahk_id %in_control%
	;PostMessage, %WM_SYSKEYDOWN%, 0x33, 0,, ahk_id %in_control%
	;PostMessage, %WM_SYSKEYUP%, 0x33, 0xC0000000,, ahk_id %in_control%
	;PostMessage, %WM_KEYUP%, 0x12, 0xC0380001,, ahk_id %in_control%
	
	;PostMessage, 0x0100, 0x12, 0x01000000,, ahk_id %in_control%	; WM_SYSKEYDOWN, ALT
	;PostMessage, 0x0102, 0x33, 0x60000000,, ahk_id %in_control%	; WM_SYSKEYDOWN, 3
	;PostMessage, 0x0101, 0x33, 0xC0000000,, ahk_id %in_control%		; WM_SYSKEYUP, 3
	;PostMessage, 0x0101, 0x12, 0xC0000000,, ahk_id %in_control%		; WM_KEYUP, ALT
	
	;PostMessage, 0x0104, 0x12, 55555555,, ahk_id %in_control%	; WM_SYSKEYDOWN, ALT
	;PostMessage, 0x0104, 0x33, 20040001,, ahk_id %in_control%	; WM_SYSKEYDOWN, 3
	;PostMessage, 0x0105, 0x33, E0040001,, ahk_id %in_control%		; WM_SYSKEYUP, 3
	;PostMessage, 0x0101, 0x12, C0380001,, ahk_id %in_control%		; WM_KEYUP, ALT
	
	;PostMessage, %WM_MOUSEMOVE%, 0, 0x03C101AF,, ahk_id %in_control%
	;PostMessage, %WM_LBUTTONDOWN%, 0x0000, 0x03C101AF,, ahk_id %in_control%
	;PostMessage, %WM_LBUTTONUP%, 0, 0x03C101AF,, ahk_id %in_control%
	
	;ControlClick("x434 y631", "CrossWorlds 2", , "Left", 1, "NA")
	
} ; Added bracket before function

; ,::{
; 	MouseClick("L" ,882, 684, 1, 0)
; }

; .::{
; 	MouseClick("L" ,1026, 681, 1, 0)
; }

; /::{
; 	MouseClick("L" ,1177, 686, 1, 0)
; }

;;startSpamFnToCurrentCtrl;;
startSpamFnToCurrentCtrl( fnName, period, toggle := false, fnParams* ){
	; to spam an input function to current active control
	; Input
	;  - fnName		: fn name to be spam
	;  - period 	: a period of time to spam specified fn
	;  - toggle		: True -> will start the spam if not yet existed, else False -> stop the timer
	;  - fnParams 	: additional parameter which will be forward to target function
	
	; an array object storing a running spam fn
	global ctrlMap

	; get the control from current active window, which will be use in SetTimer to send key to the background window via control
	hWnd := WinExist("A")
	
	; the key which will be used when storing/checking running spam fn
	mapkey := fnName . "-" . hWnd
	
	; check if the spam is already active
	if( ctrlMap.Has(mapkey) ){
		; if already exist then skip the process
		; check if toggle mode
		if( toggle ){
			; toggle mode then stop the timer
			genToolTip( "Stop  <" fnName ">" )
			SetTimer(ctrlMap[mapkey],0)
			ctrlMap.Delete(mapkey)
		}else{
			; if not toggle mode then just raise message and skip the process
			genToolTip( "<" mapkey "> is already actived" )
		}
	}else{

		genToolTip( "Start spam <" fnName ">" )
		
		; prepare function object for setting timer
		; create fn object from input fnNme and parameter
		if ( fnParams.Length == 0 ){
			spamFnObj := %fnName%.bind(hWnd)
		}else{
			spamFnObj := %fnName%.bind(hWnd, fnParams*)
		}
		
		; keep key map of hwnd -> fn object for later use in deleting timer
		; use hwnd as a key by converting it to string
		ctrlMap[mapkey] := spamFnObj

		; start the loop
		SetTimer(spamFnObj,period)
	}
	
	return

}

stopSpamFnToCurrentCtrl( fnName ){

	; to stop the running spam process
	; Input
	;  - fnName		: fn name to be stop

	; an array object storing a running spam fn
	global ctrlMap

	; get the hwnd of current window
	hWnd := WinExist("A")

	; the key which will be used when storing/checking running spam fn
	mapkey := fnName . "-" . hWnd
	
	; check if process is running
	if( !ctrlMap.Has(mapkey) ){
		debugMsg( "No spam process running" )
		return
	}
	
	debugMsg( "Stop spamming <" mapkey ">" )
	spamFn := ctrlMap[mapkey]
	; stop the timer using fn obj as a key
	SetTimer(spamFn,0)
	; remove the key from array
	ctrlMap.Delete(mapkey)

	return
}


; function to check if window is half width (use when snap left/right of the screen)
isWinNormalRatio(){

	curWin := WinExist("A")
	getClientSize( curWin, &width, &height )
	
	sizeRatio := width / height
	
	if( sizeRatio > 1.7 && sizeRatio < 2 ){
		return true
	}else{
		return false
	}
	
}

;;nino_burst;;
nino_burst( in_control ){

	global WM_KEYDOWN
	global WM_KEYUP
	
	; use SendMessage to send keystroke to inactive windows
	; (PostMessage will cause an issue where some message trigger too fast because of async)
	; Use SendMessage instead of using ControlSend which will interrupt the physical keystroke
	
	; send message pattern copy from the result of Spy++
	
	; SendMessage, <command type>, <key to be send>, <lparam>,, wintitle
	; 0x12 = alt
	; 0x33 = 3
	; <Key list>: https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
	; <command type> : https://documentation.help/AutoHotkey-GUI/SendMessageList.htm
	; <lparam>
	;	- for modifier key (alt, ctrl) bits 24 must be 1 (0x?1??????)
	;	- keydown for normal key can be 0
	;	- for ant keyup bit 30,31 must be 1 (0xC???????)
	; more info about lparam => https://learn.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
	ErrorLevel := SendMessage(WM_KEYDOWN, 0x12, 0x01000000, , "ahk_id " in_control)	; keydown, alt
	Sleep(40)
	ErrorLevel := SendMessage(WM_KEYDOWN, 0x33, 0, , "ahk_id " in_control)		; keydown, 3
	ErrorLevel := SendMessage(WM_KEYUP, 0x33, 0xC0000000, , "ahk_id " in_control)	; keyup, 3
	;Sleep(40)
	ErrorLevel := SendMessage(WM_KEYUP, 0x12, 0xC1000000, , "ahk_id " in_control)	; keyup, alt
	
	return
}

nino_imagen( in_control, in_imagenSlot ){

	global WM_KEYDOWN
	global WM_KEYUP
	
	;ControlSend,,{blind}{LCtrl down}{%in_imagenSlot%}{LCtrl up}, ahk_id %in_control%
	
	; post message pattern copy from the result of Spy++
	; 0x11 = ctrl
	; 0x31 = 1

	ErrorLevel := SendMessage(WM_KEYDOWN, 0x11, 0x01000000, , "ahk_id " in_control)	; keydown, ctrl
	Sleep(50)
	ErrorLevel := SendMessage(WM_KEYDOWN, 0x31, 0, , "ahk_id " in_control)		; keydown, 1
	ErrorLevel := SendMessage(WM_KEYUP, 0x31, 0xC0000000, , "ahk_id " in_control)	; keyup, 1
	;Sleep(50)
	ErrorLevel := SendMessage(WM_KEYUP, 0x11, 0xC1000000, , "ahk_id " in_control)	; keyup, ctrl
	
}

nino_altCombine( in_key ){
	SetKeyDelay(-1,-1)
	Send "{Alt Down}"
	Send "{" in_key "}"
	sleep 40
	Send "{Alt Up}"
}


nino_ctrlCombine( in_key ){
	SetKeyDelay(-1,-1)
	Send "{Ctrl Down}"
	Send "{" in_key "}"
	sleep 40
	Send "{Ctrl Up}"
}

nino_click( in_xpos := -1, in_ypos := -1, rand_range_x := 15, rand_range_y := 15 ){
; click with random offset in position

	; if no x,y position input then use the current mouse position
	if( in_xpos = -1 or in_ypos = -1 ){
		MouseGetPos(&in_xpos, &in_ypos)
	}
	; always put some random offset in position just for sure
	xpos := randomInput( in_xpos, rand_range_x )
	ypos := randomInput( in_ypos, rand_range_y )
	
	MouseClick("left", xpos, ypos, , 0)
}

nino_click_ratio( in_xpos, in_ypos, rand_range_x := 1, rand_range_y := 1, hold_time := 0 ){
; click the position which input as percentage of window client W x H
	; Parameter
	; - in_xpos : x position as percentage
	; - in_ypos : y position as percentage
	; - rand_range_x : offset for x pos as percentage
	; - rand_range_y : offset for y pos as percentage

	; get window client width x height
	curWin := WinExist("A")
	getClientSize( curWin, &cWidth, &cHeight )
	; convert input percentage to exact pixel on window
	xpos := cWidth * in_xpos / 100
	ypos := cHeight * in_ypos / 100
	
	; calculate exact pixel for offset
	rand_x := cWidth * rand_range_x / 100
	rand_y := cHeight * rand_range_y / 100
	
	; random the x y position with offset
	xpos := randomInput( xpos, rand_x )
	ypos := randomInput( ypos, rand_y )
	
	if ( hold_time == 0 ){
		MouseClick("left", xpos, ypos, , 0)
	}else if ( hold_time > 0 ){
		MouseClick("left", xpos, ypos, , 0, "D")
		Sleep(hold_time)
		MouseClick("left", , , , , "U")
	}
}

nino_spamClick( in_xpos, in_ypos ){

	SetMouseDelay(-1)

	; left click on the position with random offset
	nino_click( in_xpos, in_ypos, 10, 10 )

	return
}

; hotkey which activate when nino kuni is open (even without focus)
#HotIf WinExist(zWinTitle)

; focus window by input hotkey
#Numpad1::
#Numpad2::
#Numpad3::
#Numpad4::
#Numpad5::
#Numpad6::
#Numpad7::
#Numpad8::
	; use last string of input hotkey and as a key for array
{ ; V1toV2: Added bracket
	key := Integer(SubStr(A_ThisHotkey, -1))

	; try derive handler from the list
	hWnd := nino_windows.Has(key) ? nino_windows[key] : ""
	
	; if no handler found in the list, check if there is already window with matching name exist
	; - this case will happen when windows name are already set, but the script has been reload

	if( hWnd == "" ){
	
		winTitle := "CrossWorlds " . key
		; get hWnd/unique id of current active window
		hWnd := WinExist(winTitle)
		
		; if window found then
		if( hWnd != 0 ){
			; keep hWnd for each window in array for later use
			nino_windows[key] := hWnd
		}else{
			return
		}
	}
	
	; if selected window is already active, then minimize it
	if( winActive("ahk_id " hWnd ) ){
		WinMinimize("A")
	} else {
		WinActivate("ahk_id " hWnd)
	}
} ; Added bracket before function

; activate/call all nnk client windows
#Numpad0::
#F11::
{ ; V1toV2: Added bracket
	owinList := WinGetList("ahk_group nnk",,,)
	awinList := Array()
	winList := owinList.Length
	For v in owinList
	{   awinList.Push(v)
	}
	Loop awinList.Length
		GroupActivate("nnk")
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

#NumpadMult::
{ ; V1toV2: Added bracket
	Loop 4 {
		if( hWnd := WinExist("CrossWorlds " A_Index ) ){
			WinActivate( "ahk_id " hWnd )
		}
	}
		
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

; #NumpadSub::
; { ; V1toV2: Added bracket
; 	Loop 4 {
; 		ind := A_Index + 4
; 		if( hWnd := WinExist("CrossWorlds " ind ) ){
; 			WinActivate( "ahk_id " hWnd )
; 		}
; 	}
; return
; } ; V1toV2: Added Bracket before hotkey or Hotstring

; minimize all nnk client
#NumpadDot::
#F12::
{ ; V1toV2: Added bracket
	WinMinimize("ahk_group nnk")
} ; V1toV2: Added bracket in the end


; arrange and snap nnk client windows according to windows name
#NumpadSub::
{ ; V1toV2: Added bracket
	SetKeyDelay(-1)
	for key, hWnd in nino_windows{
		WinActivate("ahk_id" hWnd)
		Send("#{z}")
		Sleep(200)
		Send("{5}")
		Send("{" key "}")
	}
	return
}

;==-


#HotIf WinActive( "ahk_exe metaworld.exe" )

#/::{ ; V1toV2: Added bracket
	; derive user/pw from defined list

	user := userlist["nino4"][1]
	pw := userlist["nino4"][2]
	
	Send("^a")
	SendInput("{text}" user)
	Send("{Tab}")
	Send("^a")
	SendInput("{text}" pw)
} ; V1toV2: Added bracket in the end



;======================================================
;	D E E P L
;================================================== -==

#HotIf WinActive( "ahk_exe DeepL.exe " )
Tab::
{ ; V1toV2: Added bracket
	Send("{Tab}")
	Sleep(30)
	Send("+{Tab}")
	Return
} ; V1toV2: Added bracket in the end
;==-
;======================================================
;	A N K I
;================================================== -==
; Browser

#HotIf ( WinActive("ahk_exe anki.exe") and WinActive("Browse") )
XButton1::
{ ; V1toV2: Added bracket
	L_BrowserSearch()
	Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

^NumpadAdd::
{ ; V1toV2: Added bracket
	L_BrowserSearch()
	Return
} ; Added bracket before function
	
L_BrowserSearch()
{ ; V1toV2: Added bracket
	search_field := "Key" 
	; backup clipboard value for later reset
	pre_clipboard := A_Clipboard
	A_Clipboard := search_field . ":" . A_Clipboard
	Send("^{f}")					; focus search input + highlight all existing text for replacing
	; auto type will cause bug when language is set to kana input
	; so ; changing clipboard and use ^v instead
	;Send {Text}%search_field%:%Clipboard% 	; auto type search keyword
	Send("^{v}")
	Send("{Enter}")
	
	; reset clipboard
	Sleep(100)
	A_Clipboard := pre_clipboard
}

;==-

;======================================================
;	V O C A B   S E A R C H
;================================================== -==
/*
#IfWinActive

;!w::a

; just catch the ^c event for later check with vocab search hotkey
; [~] is pass-through modifier its key's native function will not be blocked  
} ; V1toV2: Added Bracket before hotkey or Hotstring
~^c::return

; Press Ctrl + c + Num0 to copy selected text and call up DeepL with setting hotkey
$^Numpad0::
{ ; V1toV2: Added bracket
	if (A_PriorHotKey = "~^c" AND A_TimeSincePriorHotkey < 1000){
		; setting hotkey in DeepL as "Ctrl + Alt + Shift + c"
		Send ^!+{c}
	}
	return

; Press Ctrl + c + 1 to copy selected text and search in jisho.org
} ; V1toV2: Added Bracket before hotkey or Hotstring
$^1::ctrlCCheck( "jishoSearch" )
$^Numpad1::ctrlCCheck( "jishoSearch" )
	
;; Press Ctrl + c + 2 to copy selected text and search in nozomibot
;$^2::ctrlCCheck( "nozomiSearch" )
;$^Numpad2::ctrlCCheck( "nozomiSearch" )

; Press Ctrl + c + 2 to copy selected text and search in nozomibot
$^2::ctrlCCheck( "jtdicSearch" )
$^Numpad2::ctrlCCheck( "jtdicSearch" )

; Press Ctrl + c + 3 to copy selected text and search in wanikani
$^3::ctrlCCheck( "wanikaniSearch" )
$^Numpad3::ctrlCCheck( "wanikaniSearch" )

; Press Ctrl + c + 4 to copy selected text and search in longdo
$^4::ctrlCCheck( "longdoSearch" )
$^Numpad4::ctrlCCheck( "longdoSearch" )

; Press Ctrl + c + 5 to copy selected text and search in neocities
$^5::ctrlCCheck( "neocitiesSearch" )
$^Numpad5::ctrlCCheck( "neocitiesSearch" )

; Press Ctrl + c + 6 to copy selected text and search in tangorin
$^Numpad6::ctrlCCheck( "tatoebaSearch" )

; Press Ctrl + c + 7 to copy selected text and search in bonten
$^Numpad7::ctrlCCheck( "bontenSearch" )

; Press Ctrl + c + 8
$^Numpad8::ctrlCCheck( "ysSearch" )

; Press Ctrl + c + 9
$^Numpad9::ctrlCCheck( "kisekiSearch" )
*/
;==-

;======================================================
;	D E F A U L T   H O T K E Y
;================================================== -==

; default hotkey
#HotIf

; run all netmarble launcher with specified user
#+NumpadAdd::
{ ; V1toV2: Added bracket
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher8.lnk")
	Sleep(2000)
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher7.lnk")
	Sleep(2000)
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher6.lnk")
	Sleep(2000)
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher5.lnk")
	Sleep(2000)
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher4.lnk")
	Sleep(2000)
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher3.lnk")
	Sleep(2000)
	RunWait("C:\Users\m-local\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Launcher2.lnk")
	Sleep(2000)
	RunWait("C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Netmarble Launcher.lnk")
return

; Test script
} ; V1toV2: Added Bracket before hotkey or Hotstring
#+k::genToolTip( A_ScriptName . " script is running")

; Reload script
#+r::Reload()

; Pause script
#+p::
{ ; V1toV2: Added bracket
	Suspend()
	Pause()
} ; V1toV2: Added Bracket before hotkey or Hotstring

; Switch debug mode
#+d::
{
	if( gv_debug = 0 ){
		gv_debug := "1"
		genToolTip( "Debug mode on" )
	}else{
		gv_debug := "0"
		genToolTip( "Debug mode off" )
	}
}

; Backup script file to specified folder ( in current working dir )
#+b::
{ ; V1toV2: Added bracket
	genBackupInDir( gv_backupDir )
} ; V1toV2: Added Bracket before hotkey or Hotstring

; copy current mouse position as ratio to the client WxH to clipboard as percentage format "x, y"

^#c::
{ ; V1toV2: Added bracket
	ratio_mode := false
	
	CoordMode("Mouse", "Client")
	; 
	curWin := WinExist("A")
	getClientSize( curWin, &width, &height )
	MouseGetPos(&x, &y)
	
	x_ratio := x / width * 100
	y_ratio := y / height * 100

	if(ratio_mode){
		A_Clipboard := x_ratio . ", " . y_ratio
		msg := "ratio mode : " x_ratio "%, " y_ratio "%"
	}else{
		A_Clipboard := x . ", " . y
		msg := "fix mode : " x ", " y ""
	}
	
	
	genToolTip( msg )
	
} ; Added bracket before function

; Edit script file with Notepad++
#+e::
{ ; V1toV2: Added bracket
	;Run("`"C:\Program Files\Notepad++\notepad++.exe`" " A_ScriptFullPath)
	Run("`"C:\Program Files\Microsoft VS Code\Code.exe`"")
return
} ; V1toV2: Added bracket in the end

^!Numpad7::{
	MsgBox WinActive( "ahk_exe ProjectN-Win64-Shipping.exe" )
}



