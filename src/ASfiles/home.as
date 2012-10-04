import components.home.preferencesWindow;

import external.*;

import flash.events.MouseEvent;

import flashx.textLayout.compose.TextLineRecycler;

import mx.controls.Alert;
import mx.core.DragSource;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;
import mx.events.DataGridEvent;
import mx.events.DragEvent;
import mx.events.ValidationResultEvent;
import mx.managers.DragManager;
import mx.managers.PopUpManager;

import spark.components.Image;
import spark.events.IndexChangeEvent;
import spark.filters.DropShadowFilter;

[Bindable] public var viewMode:String = "loggedIn";	//Button View = "loggedIn", Widget View = "widgetView" (to match the state names).

//this.stage.displayState = StageDisplayState.FULL_SCREEN;
/* public function updateBreadcrumb(action:String):void {
if(action == 'messages') {
if(viewStackMessages.selectedIndex > 0) {
lblBreadcrumbCategory.visible = lblBreadcrumbCategory.includeInLayout = false;
btnBreadcrumbCategory.visible = btnBreadcrumbCategory.includeInLayout = lblMarkerSubcategory.visible = lblBreadcrumbSubcategory.visible = true;
lblBreadcrumbSubcategory.text = viewStackMessages.selectedChild.label;
}
else {
lblBreadcrumbCategory.visible = lblBreadcrumbCategory.includeInLayout = true;
btnBreadcrumbCategory.visible = btnBreadcrumbCategory.includeInLayout = lblMarkerSubcategory.visible = lblBreadcrumbSubcategory.visible = false;
}
}
} */

[Bindable] public var fullname:String;
[Bindable] private var registeredUserID:String = "thisValueWillBeReplaced";
[Bindable] private var registeredPassword:String = "thisValueWillBeReplaced";
protected function btnLogin_clickHandler(event:MouseEvent):void {
	if(userID.text == 'pipi' || (userID.text == 'piim' && password.text == 'password') || (userID.text == 'james' && password.text == 'archer') || (userID.text == 'melissa' && password.text == 'archer') || (userID.text == 'tiffany' && password.text == 'janeway') || (userID.text == 'robert' && password.text == 'janeway') || (userID.text == 'albert' && password.text == 'sisko') || (userID.text == 'doris' && password.text == 'sisko') || (userID.text == registeredUserID && password.text == registeredPassword)) {
		this.currentState=viewMode;
		
		if(userID.text == 'pipi' || (userID.text == 'piim' && password.text == 'password')) fullname = "Isaac Goodman";
		else if(userID.text == 'james' && password.text == 'archer') fullname = "James Archer";
		else if(userID.text == 'melissa' && password.text == 'archer') fullname = "Melissa Archer";
		else if(userID.text == 'tiffany' && password.text == 'janeway') fullname = "Tiffany Janeway";
		else if(userID.text == 'robert' && password.text == 'janeway') fullname = "Robert Janeway";
		else if(userID.text == 'albert' && password.text == 'sisko') fullname = "Albert Sisko";
		else if(userID.text == 'doris' && password.text == 'sisko') fullname = "Doris Sisko";
		//else, fullname will contain the name the user indicated at registration.
		
		clearValidationErrorsLogin();
		bcLogin.height = 328;
	}
	else {
		usernameValidator.validate('');		//here we are forcing the userID and password text fields to show red borders, by validating them as if they had empty values.
		passwordValidator.validate('');
		hgLoginFail.visible = hgLoginFail.includeInLayout = true;
		bcLogin.height = 346;
		//this.currentState='default';
	}
}

//private var vResult:ValidationResultEvent;
protected function createAccountHandler():void {
	var isInputInvalid:Boolean = false;
	
	vResult = firstNameValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = lastNameValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = birthDateValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = ssnValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = userIDValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = emailValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = password2Validator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	vResult = passwordConfValidator.validate();
	if(vResult.type == ValidationResultEvent.INVALID) isInputInvalid = true;
	
	if(password2.text != passwordConf.text) {
		passwordConf.errorString = "Password was not confirmed correctly";
		isInputInvalid = true;
	}
	
	if(isInputInvalid) {
		hgLoginFail.visible = hgLoginFail.includeInLayout = true;
		bcLogin.height = 418;
	}
	else {
		registeredUserID = userID2.text;
		registeredPassword = password2.text;
		fullname = titleCase(firstName.text.toLowerCase() + " " + lastName.text.toLowerCase());
		
		firstName.text = lastName.text = userID2.text = emailAddress.text = password2.text = passwordConf.text = "";
		dateOfBirth.text = "MM/DD/YYYY";
		ssn.text = '000-00-0000';
		clearValidationErrors();
		//bcLogin.height = 400;
		
		this.currentState = 'default';
		Alert.show("You may now log in with the user ID and password you just selected","Login");
	}
}

//http://www.parorrey.com/blog/flash-development/as3-convert-string-to-titlecase-in-flash-using-actionscript-function/
//also called from myAddMedication2Window.mxml
public function titleCase(txt:String):String {
	txt = txt.split(" ").map(function(myElement:String, myIndex:int, myArr:Array):String {
		return myElement.substr(0, 1).toLocaleUpperCase() + myElement.substr(1);
	}).join(" ");
	
	return txt;
}

/* private function capitalize(str:String):String {
return str.substr(0,1).toUpperCase() + str.substr(1).toLowerCase();
} */

private function clearValidationErrors():void {
	hgLoginFail.visible = hgLoginFail.includeInLayout = false; 
	firstNameValidator.validate('dummy');	//these dummies clear all validation errors
	lastNameValidator.validate('dummy');
	birthDateValidator.validate('12/12/2012');
	ssnValidator.validate('123-12-1234');
	userIDValidator.validate('dummy');
	emailValidator.validate('dummy@dummy.com');
	password2Validator.validate('dummy2');
	passwordConfValidator.validate('dummy2');
}

//private function clearValidationErrorsLogin():void... (SHARED)

//private function forgotPasswordHandler():void... (SHARED)

protected function dropDownView_changeHandler(event:IndexChangeEvent):void
{
	// TODO Auto-generated method stub
	/*if(dropDownView.selectedIndex == 0) {
	currentState == 'loggedIn' ? currentState = 'widgetView' : currentState = 'loggedIn';
	dropDownView.selectedIndex = -1;
	}*/
	
	var myPreferencesWindow:preferencesWindow = preferencesWindow(PopUpManager.createPopUp(this, preferencesWindow) as spark.components.TitleWindow);
	myPreferencesWindow.viewStackPreferences.selectedIndex = event.newIndex;
	PopUpManager.centerPopUp(myPreferencesWindow);
	dropDownView.selectedIndex = -1;
	/*var myClass:myClassesWindow = myClassesWindow(PopUpManager.createPopUp(this, myClassesWindow) as spark.components.TitleWindow);
	if(reqClass != '') myClass.showClass(reqClass);
	PopUpManager.centerPopUp(myClass);
	stackViews.selectedIndex = 1;
	*/
	
}

/* private function saveTaskTime():void {
var now:Date = new Date();
fileReference.save(now.toString(), "timelog.txt");
} */

[Bindable] [Embed('images/messages.png')] private var imgMessages:Class;
[Bindable] [Embed('images/appointments.png')] private var imgAppointments:Class;
[Bindable] [Embed('images/medicalRecords.png')] private var imgMedicalRecords:Class;
[Bindable] [Embed('images/immunizations.png')] private var imgImmunizations:Class;
[Bindable] [Embed('images/vitalSigns.png')] private var imgVitalSigns:Class;
[Bindable] [Embed('images/exercise.png')] private var imgExercise:Class;
[Bindable] [Embed('images/nutrition.png')] private var imgNutrition:Class;
[Bindable] [Embed('images/educationalResources.png')] private var imgEducationalResources:Class;
[Bindable] [Embed('images/communityGroup.png')] private var imgCommunityGroup:Class;
[Bindable] [Embed('images/medications.png')] private var imgMedications:Class;

// Initializes the drag and drop operation.
private function buttonViewMoveHandler(event:MouseEvent, rollOverImg:Class):void {
	var dragInitiator:mx.controls.Button=mx.controls.Button(event.currentTarget);
	var ds:DragSource = new DragSource();
	var imgRollover:Image = new Image();
	imgRollover.source = rollOverImg;
	DragManager.doDrag(dragInitiator, ds, event, imgRollover);
}

// Called when the user moves the drag indicator onto the drop target.
private function buttonViewDragEnterHandler(event:DragEvent):void {
	var dropTarget:mx.controls.Button=mx.controls.Button(event.currentTarget);
	DragManager.showFeedback(DragManager.COPY);
	DragManager.acceptDragDrop(dropTarget);
}

// Called if the target accepts the dragged object and the user releases the mouse button while over the target. 
private function buttonViewDragDropHandler(event:DragEvent, target:mx.controls.Button):void {
	var index:int = buttonsTileGroup.getChildIndex(target);
	buttonsTileGroup.addElementAt(buttonsTileGroup.removeElement(mx.controls.Button(event.dragInitiator)),index);
}    

[Bindable] private var widgetLibraryOpen:Boolean = false;
[Bindable] private var widgetMessagesOpen:Boolean = true;
[Bindable] private var widgetAppointmentsOpen:Boolean = true;
[Bindable] private var widgetMedicalRecordsOpen:Boolean = true;
[Bindable] private var widgetImmunizationsOpen:Boolean = true;
[Bindable] private var widgetVitalSignsOpen:Boolean = true;
[Bindable] private var widgetEducationalResourcesOpen:Boolean = true;
[Bindable] private var widgetExerciseOpen:Boolean = true;
[Bindable] private var widgetMedicationsOpen:Boolean = true;
[Bindable] private var widgetNutritionOpen:Boolean = true;
[Bindable] [Embed("images/btnWidgetTriggerOpen.png")] public var widgetTriggerOpen:Class;
[Bindable] [Embed("images/btnWidgetTriggerClose.png")] public var widgetTriggerClose:Class;

public function falsifyWidget(widget:String):void {
	if(widget == 'modMessages') widgetMessagesOpen = false;
	else if(widget == 'modCalendar') widgetAppointmentsOpen = false;
	else if(widget == 'modMedicalRecords') widgetMedicalRecordsOpen = false;
	else if(widget == 'modImmunizations') widgetImmunizationsOpen = false;
	else if(widget == 'modVitalSigns') widgetVitalSignsOpen = false;
	else if(widget == 'modEducationalResources') widgetEducationalResourcesOpen = false;
	else if(widget == 'modExercise') widgetExerciseOpen = false;
	else if(widget == 'modMedications') widgetMedicationsOpen = false;
	else if(widget == 'modNutrition') widgetNutritionOpen = false;
}