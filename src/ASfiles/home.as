import ASclasses.Constants;
import ASclasses.PatientConstants;

import components.home.preferencesWindow;
import components.popups.myAppointmentsWindow;
import components.popups.myClassesWindow;

import controllers.AppointmentsController;
import controllers.ImmunizationsController;
import controllers.MainController;
import controllers.MedicalRecordsController;
import controllers.MedicationsController;

import events.ApplicationDataEvent;
import events.ApplicationEvent;
import events.AppointmentEvent;

import external.*;
import external.TabBarPlus.plus.TabBarPlus;
import external.TabBarPlus.plus.TabPlus;
import external.TabBarPlus.plus.tabskins.TabBarPlusSkin;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import flashx.textLayout.compose.TextLineRecycler;

import models.ApplicationModel;
import models.modules.AppointmentsModel;

import mx.collections.IList;
import mx.controls.Alert;
import mx.controls.TabBar;
import mx.core.DragSource;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;
import mx.events.DataGridEvent;
import mx.events.DragEvent;
import mx.events.ListEvent;
import mx.events.ValidationResultEvent;
import mx.managers.DragManager;
import mx.managers.PopUpManager;

import spark.components.Image;
import spark.events.IndexChangeEvent;
import spark.filters.DropShadowFilter;

import styles.ChartStyles;

import util.ChartLabelFunctions;
import util.DateFormatters;
import util.DateUtil;

[Bindable] public var chartStyles:ChartStyles;
[Bindable] public var controller:MainController;
[Bindable] public var model:ApplicationModel;

private var appointmentsController:AppointmentsController;
private var immunizationsController:ImmunizationsController;
[Bindable] private var medicalRecordsController:MedicalRecordsController;
private var medicationsController:MedicationsController;

protected function init():void
{
	controller = AppProperties.getInstance().controller as MainController;
	model = controller.model as ApplicationModel;
	
	model.chartStyles = chartStyles = new ChartStyles();
	
	appointmentsController = controller.appointmentsController;
	immunizationsController = controller.immunizationsController;
	medicalRecordsController = controller.medicalRecordsController;
	medicationsController = controller.medicationsController;
	
	chartStyles = new ChartStyles();
}

protected function onShowPreferences(event:IndexChangeEvent):void
{
	var popup:preferencesWindow = controller.showPreferences() as preferencesWindow;
	popup.viewStackPreferences.selectedIndex = event.newIndex;
	
	dropDownView.selectedIndex = -1;
}

/* private function saveTaskTime():void {
var now:Date = new Date();
fileReference.save(now.toString(), "timelog.txt");
} */

[Bindable] [Embed('/images/messages.png')] private var imgMessages:Class;
[Bindable] [Embed('/images/appointments.png')] private var imgAppointments:Class;
[Bindable] [Embed('/images/medicalRecords.png')] private var imgMedicalRecords:Class;
[Bindable] [Embed('/images/immunizations.png')] private var imgImmunizations:Class;
[Bindable] [Embed('/images/vitalSigns.png')] private var imgVitalSigns:Class;
[Bindable] [Embed('/images/exercise.png')] private var imgExercise:Class;
[Bindable] [Embed('/images/nutrition.png')] private var imgNutrition:Class;
[Bindable] [Embed('/images/educationalResources.png')] private var imgEducationalResources:Class;
[Bindable] [Embed('/images/communityGroup.png')] private var imgCommunityGroup:Class;
[Bindable] [Embed('/images/medications.png')] private var imgMedications:Class;

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
[Bindable] [Embed("/images/btnWidgetTriggerOpen.png")] public var widgetTriggerOpen:Class;
[Bindable] [Embed("/images/btnWidgetTriggerClose.png")] public var widgetTriggerClose:Class;

public function falsifyWidget(widget:String):void {
	if(widget == Constants.MODULE_MESSAGES) widgetMessagesOpen = false;
	else if(widget == Constants.MODULE_APPOINTMENTS) widgetAppointmentsOpen = false;
	else if(widget == Constants.MODULE_MEDICAL_RECORDS) widgetMedicalRecordsOpen = false;
	else if(widget == Constants.MODULE_IMMUNIZATIONS) widgetImmunizationsOpen = false;
	else if(widget == Constants.MODULE_VITAL_SIGNS) widgetVitalSignsOpen = false;
	else if(widget == Constants.MODULE_EDUCATIONAL_RESOURCES) widgetEducationalResourcesOpen = false;
	else if(widget == Constants.MODULE_EXERCISE) widgetExerciseOpen = false;
	else if(widget == Constants.MODULE_MEDICATIONS) widgetMedicationsOpen = false;
	else if(widget == Constants.MODULE_NUTRITION) widgetNutritionOpen = false;
}
