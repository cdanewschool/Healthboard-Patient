/**
 * NOTE: This file has been deprecated, and has been replaced by MedicationsController, MedicationsModel and MedicationsModule.
 */
import medications.medTips;
import popups.myChartPopupWindow;
import components.medications.myRequestRenewalWindow;

import mx.charts.events.ChartItemEvent;
import mx.managers.PopUpManager;

private function showMedTip():void {
	var myTipWindow:medTips = medTips(PopUpManager.createPopUp(this, medTips) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myTipWindow);
}

private var myChartPopup:myChartPopupWindow;
private function updateIntake(e:ChartItemEvent):void {
	e.hitData.item.taken = !e.hitData.item.taken;
	medicationsData.refresh();		//this ensures that the chart points get colored/uncolored upon clicking them, by refreshing the chart's data provider.
	PopUpManager.removePopUp(myChartPopup);		//remove existing popup (if any).
	if(e.hitData.item.taken) {
		myChartPopup = myChartPopupWindow(PopUpManager.createPopUp(this, myChartPopupWindow) as spark.components.TitleWindow);
		myChartPopup.med = e.hitData.item;
		myChartPopup.medName = e.hitData.item.name;
		var myDate:String;
		/*if(e.hitData.item.dateP != null) myDate = e.hitData.item.dateP;
		else if(e.hitData.item.dateO != null) myDate = e.hitData.item.dateO;
		else if(e.hitData.item.dateS != null) myDate = e.hitData.item.dateS;
		else if(e.hitData.item.dateH != null) myDate = e.hitData.item.dateH;*/
		if(e.hitData.item.dateAN != null) myDate = e.hitData.item.dateAN;
		else if(e.hitData.item.date != null) myDate = e.hitData.item.date;
		myChartPopup.medDate = myDate.substr(0,10);
		myChartPopup.medHour = myDate.substr(11,2);		//(myDate.substr(12,1) == ":") ? "0" + myDate.substr(11,1) : myDate.substr(11,2);
		myChartPopup.medMeridiem = myDate.substr(-2);
		myChartPopup.move(e.stageX + 11,e.stageY - myChartPopup.height - 12);
	}
}

//this is a "clone" of the function in MedicationDetails.mxml. This one is called from the main file (for the button on the right column)...
public function requestRenewal(medicationData:Object):void {
	var myRequestRenewal:myRequestRenewalWindow = myRequestRenewalWindow(PopUpManager.createPopUp(this, myRequestRenewalWindow) as spark.components.TitleWindow);
	myRequestRenewal.medNameDosage = medicationData.dose != '' ? medicationData.name + ' - ' + medicationData.dose : medicationData.name;
	PopUpManager.centerPopUp(myRequestRenewal);
}