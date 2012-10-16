/**
 * NOTE: This file has been deprecated, and has been replaced by MedicalRecordsController, MedicalRecordsModel and MedicalRecordsModule.
 */
import ASclasses.MyCustomDataTip;

import components.medicalRecords.ServiceDetails;
import components.medicalRecords.myNextStepsHistoryWindow;

import mx.charts.ChartItem;
import mx.charts.DateTimeAxis;
import mx.charts.HitData;
import mx.charts.events.ChartItemEvent;
import mx.charts.series.items.PlotSeriesItem;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.ListEvent;
import mx.graphics.IFill;
import mx.graphics.SolidColor;
import mx.managers.FocusManager;
import mx.managers.PopUpManager;
import mx.messaging.AbstractConsumer;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectProxy;
import mx.utils.ObjectUtil;

import spark.components.TitleWindow;
import spark.events.IndexChangeEvent;

[Bindable] public var wasModuleCreated:Boolean = false;

/**
 * This function only runs the very first time the Medical Records module is created/opened.
 * Its purpose is to check if the module is being opened from the "Appointments" module (there's a link under completed appts to "View Medical Record").
 * If so, we show the corresponding medical record/
 */
private function handleIfFromAppts():void {
	if(wasModuleCreated) {		//this will only be true if being called from the appts menu, before the Medical Records module was created.
		var index:int = monthView.selectedApptMedRecIndex;
		viewServiceDetails(medicalRecordsData.getItemAt(index));
	}
	else wasModuleCreated = true;		//this is used to tell the Appointments module (MonthView.as) that there the viewServiceDetails() can be called directly.
}

private function filterMedRecFromTree():void {
	medicalRecordsData.filterFunction = filterMedRec;
	medicalRecordsData.refresh();
	medicalRecordsDataGrid.filterFunction = null;
	medicalRecordsDataGrid.refresh();

	medicalRecordsCategories = new Array();
	for(var i:uint = 0; i < medicalRecordsData.length; i++) {
		if(medicalRecordsCategories.indexOf(medicalRecordsData[i].name) == -1) medicalRecordsCategories.push(medicalRecordsData[i].name);
	}
	
	updateMedRecHeightAndColors();
	
	if(medicalRecordsSearch.text != "Search medical records") {
		medicalRecordsSearch.text = "";
		lblSearchResultsMedRec.visible = btnClearSearchMedRec.visible = false;
	}
}

private function filterMedRec(item:Object):Boolean {
	var myOpenLeaves:Array = new Array();
	var arrMedRecCategories:Array = new Array("Visits","Diagnostic Studies","Surgeries","Procedures");
	var myOpenCategories:Array = new Array();
	for(var i:uint = 0; i < myTreeMedRec.openItems.length; i++) {
		myOpenCategories.push(myTreeMedRec.openItems[i].category);
	}
	
	var count:uint = 0;
	for(var x:uint = 0; x < arrMedRecCategories.length; x++) {
		myOpenLeaves.push(arrMedRecCategories[x]);
		if(myOpenCategories.indexOf(arrMedRecCategories[x]) == -1) {
			//myOpenLeaves.push(arrMedCategories[x]);
			count--;
		}
		else {
			//myOpenLeaves.push(myTree.openItems[count].category);
			for(var j:uint = 0; j < myTreeMedRec.openItems[count].children.length; j++) {
				myOpenLeaves.push(myTreeMedRec.openItems[count].children[j].category);
			}
		}
		count++;
	}
	
	return myOpenLeaves.indexOf(item.name) != -1;
	
	//return dropMediFilter.selectedIndex == 0 ? myOpenLeaves.indexOf(item.name) != -1 && item.status != "inactive" : myOpenLeaves.indexOf(item.name) != -1;
	
	//var pattern:RegExp = new RegExp("[^]*"+medicationsSearch.text+"[^]*", "i");
	//return pattern.test(item.name) || pattern.test(item.dose) || pattern.test(item.type) || pattern.test(item.prescription) || pattern.test(item.directions) || pattern.test(item.pharmacy) || pattern.test(item.lastFilledDate);
}

private function medicalRecordsFillFunction(element:ChartItem, index:Number):IFill {
	var c:SolidColor = colorMedicalRecordsOutpatient;	//blue
	var item:PlotSeriesItem = PlotSeriesItem(element);
		
	if(item.item.classification == "Inpatient") {
		c = colorMedicalRecordsInpatient;		//orange
	}
	
	return c;
}

private function dataTipsMedicalRecords(hd:HitData):String {
	var date:String = hd.item.classification == "Outpatient" ? hd.item.date : hd.item.inpdate;
	return "<i>" + hd.item.name + "</i><br><br><font color='#1D1D1B'>" + hd.item.reason + "<br>" + hd.item.provider + "<br>" + date + "</font><br><br><i>Click to view record</i>";
}

private function applyCustomDataTips():void {
	plotMedicalRecords.setStyle("dataTipRenderer",MyCustomDataTip);    
}

private function showNextStepsHistory():void {
	var myNextStepsHistory:myNextStepsHistoryWindow = myNextStepsHistoryWindow(PopUpManager.createPopUp(this, myNextStepsHistoryWindow) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myNextStepsHistory);
}

private function lblMedicalRecordsDate(item:Object, column:DataGridColumn):String {
	return item.date != null ? item.date : item.inpdate;
}

private function lblMedicalRecordsNextSteps(item:Object, column:DataGridColumn):String {
	return item.nextSteps != null ? "Yes" : "";
}

private function switchMedicalRecordsView(index:uint):void {
	viewsMedicalRecords.selectedIndex = index;
	if(index == 0) {
		btnMedicalRecordsChart.setStyle("chromeColor", 0xFF931E);
		btnMedicalRecordsList.setStyle("chromeColor", 0xB3B3B3);
	}
	else {
		btnMedicalRecordsChart.setStyle("chromeColor", 0xB3B3B3);
		btnMedicalRecordsList.setStyle("chromeColor", 0xFF931E);
	}
}

private function showServiceDetails(e:ChartItemEvent):void{
	viewServiceDetails(e.hitData.item);
}

private function showServiceDetailsDG(e:ListEvent):void {
	viewServiceDetails(e.itemRenderer.data);
}

public var arrOpenTabsMR:Array = new Array();
public function viewServiceDetails(service:Object):void {
	var isServiceAlreadyOpen:Boolean = false;
	for(var j:uint = 0; j < arrOpenTabsMR.length; j++) {
		if(arrOpenTabsMR[j] == service) {
			isServiceAlreadyOpen = true;
			viewStackMedicalRecords.selectedIndex = j + 1;		//+1 because in arrOpenTabs we don't include the first tab
			break;
		}
	}				
	if(!isServiceAlreadyOpen) {
		var serviceDetails:ServiceDetails = new ServiceDetails();
		serviceDetails.serviceData = service;
		viewStackMedicalRecords.addChild(serviceDetails);
		tabsMedicalRecords.selectedIndex = viewStackMedicalRecords.length - 1;
		arrOpenTabsMR.push(service);
	}
	medicalRecordsBottomBoxes.visible = medicalRecordsBottomBoxes.includeInLayout = false;
	//viewStackMedicalRecords.height = e.hitData.item.name == "Labs" ? 650 : 602;
	viewStackMedicalRecords.height = 602;
}

protected function tabsMedicalRecordsChangeHandler(event:IndexChangeEvent):void {
	if(tabsMedicalRecords.selectedIndex == 0) {			
		medicalRecordsBottomBoxes.visible = medicalRecordsBottomBoxes.includeInLayout = true;
		viewStackMedicalRecords.height = 406;
	}
	else {
		medicalRecordsBottomBoxes.visible = medicalRecordsBottomBoxes.includeInLayout = false;
		viewStackMedicalRecords.height = 602;
	}
}

/*
// moved to shared file
private function lblHAxisPlotChartMonth(cat:Object, pcat:Object, ax:DateTimeAxis):String {
	return dateFormatter.format(new Date(cat.fullYear, cat.month + 1, cat.dateUTC));				
}

private function lblHAxisPlotChartYear(cat:Object, pcat:Object, ax:DateTimeAxis):String {
	return dateFormatterYear.format(new Date(cat.fullYear, cat.month + 1, cat.dateUTC));				
}

private function lblHAxisPlotChartDay(cat:Object, pcat:Object, ax:DateTimeAxis):String {
	return dateFormatterDay.format(new Date(cat.fullYear, cat.month, cat.dateUTC));				
}
private function lblHAxisPlotChartDayOnly(cat:Object, pcat:Object, ax:DateTimeAxis):String {
	return dateFormatterDayOnly.format(new Date(cat.fullYear, cat.month, cat.dateUTC));				
}*/

[Bindable] private var minDateMedRec:Date = new Date( "Nov 20 2010 01:03:54 AM");
[Bindable] private var maxDateMedRec:Date = new Date( "Nov 20 2011 01:03:54 AM");

private function medicalRecordsSetMinMax():void {
	hAxisMedicalRecords.minimum = minDateMedRec;	//new Date( "Oct 1 2010 01:03:54 AM");
	hAxisMedicalRecords.maximum = maxDateMedRec;	//new Date( "Oct 1 2011 01:03:54 AM");
}

private function handleMedRecDateRange(range:String):void {
	if(range == '1d') {
		minDateMedRec = new Date( "Oct 6 2011 01:03:54 AM");
		maxDateMedRec = new Date( "Oct 8 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartDay;
		medRecVerticalGridLine.alpha = 0;
		btnMed1w.selected = btnMed1m.selected = btnMed3m.selected = btnMed1y.selected = btnMed3y.selected = btnMedAll.selected = btnMedCustom.selected = false;
	}
	else if(range == '1w') {
		minDateMedRec = new Date( "Oct 1 2011 01:03:54 AM");
		maxDateMedRec = new Date( "Oct 8 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartDay;
		medRecVerticalGridLine.alpha = 0;
		btnMed1d.selected = btnMed1m.selected = btnMed3m.selected = btnMed1y.selected = btnMed3y.selected = btnMedAll.selected = btnMedCustom.selected = false;
	}
	else if(range == '1m') {
		minDateMedRec = new Date("Sep 20 2011 01:03:54 AM");
		maxDateMedRec = new Date("Oct 20 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartDay;
		medRecVerticalGridLine.alpha = 0;
		btnMed1d.selected = btnMed1w.selected = btnMed3m.selected = btnMed1y.selected = btnMed3y.selected = btnMedAll.selected = btnMedCustom.selected = false;
	}
	else if(range == '3m') {
		minDateMedRec = new Date( "Jul 20 2011 01:03:54 AM");
		maxDateMedRec = new Date( "Oct 20 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartMonth;
		medRecVerticalGridLine.alpha = 0;
		btnMed1d.selected = btnMed1w.selected = btnMed1m.selected = btnMed1y.selected = btnMed3y.selected = btnMedAll.selected = btnMedCustom.selected = false;
	}
	else if(range == '1y') {
		minDateMedRec = new Date( "Nov 20 2010 01:03:54 AM");
		maxDateMedRec = new Date( "Nov 20 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartMonth;
		medRecVerticalGridLine.alpha = 0;
		btnMed1d.selected = btnMed1w.selected = btnMed1m.selected = btnMed3m.selected = btnMed3y.selected = btnMedAll.selected = btnMedCustom.selected = false;
	}
	else if(range == '3y') {
		minDateMedRec = new Date("Nov 20 2008 01:03:54 AM");
		maxDateMedRec = new Date("Nov 20 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartYear;
		medRecVerticalGridLine.alpha = 0.3;
		btnMed1d.selected = btnMed1w.selected = btnMed1m.selected = btnMed3m.selected = btnMed1y.selected = btnMedAll.selected = btnMedCustom.selected = false;
	}
	else if(range == 'all') {
		minDateMedRec = new Date("Nov 20 2008 01:03:54 AM");
		maxDateMedRec = new Date("Nov 20 2011 01:03:54 AM");
		hAxisMedicalRecords.labelFunction = lblHAxisPlotChartYear;
		medRecVerticalGridLine.alpha = 0.3;
		btnMed1d.selected = btnMed1w.selected = btnMed1m.selected = btnMed3m.selected = btnMed1y.selected = btnMed3y.selected = btnMedCustom.selected = false;
	}
	hAxisMedicalRecords.minimum = minDateMedRec;
	hAxisMedicalRecords.maximum = maxDateMedRec;
	
	/*for(var i:uint = 0; i < immunizationsCategories.length; i++) {
	var minDatePlus1:Date = minDate;
	minDatePlus1.setDate(minDate.getDate() + 1);
	canvas.moveTo(this.dateFormatterToday.format(minDatePlus1),this.immunizationsCategories[i]);
	canvas.lineTo(this.dateFormatterToday.format(maxDate),this.immunizationsCategories[i]);
	}*/
}

private function searchFilterMedRed():void {
	medicalRecordsData.filterFunction = filterSearchMedRed;
	medicalRecordsData.refresh();
	medicalRecordsDataGrid.filterFunction = filterSearchMedRed;
	medicalRecordsDataGrid.refresh();

	if(medicalRecordsData.length == 0) {
		plotMedicalRecords.visible = plotMedicalRecords.includeInLayout = myTreeMedRec.visible = myTreeMedRec.includeInLayout = legendMedicalRecords.visible = legendMedicalRecords.includeInLayout = medRecDGHeader.visible = medRecDGHeader.includeInLayout = medRecDGLine.visible = medRecDGLine.includeInLayout = medicalRecordsList.visible = medicalRecordsList.includeInLayout = false;
		lblNoMedicalRecords1.visible = lblNoMedicalRecords1.includeInLayout = lblNoMedicalRecords2.visible = lblNoMedicalRecords2.includeInLayout = true;
	}
	else {
		plotMedicalRecords.visible = plotMedicalRecords.includeInLayout = myTreeMedRec.visible = myTreeMedRec.includeInLayout = legendMedicalRecords.visible = legendMedicalRecords.includeInLayout = medRecDGHeader.visible = medRecDGHeader.includeInLayout = medRecDGLine.visible = medRecDGLine.includeInLayout = medicalRecordsList.visible = medicalRecordsList.includeInLayout = true;
		lblNoMedicalRecords1.visible = lblNoMedicalRecords1.includeInLayout = lblNoMedicalRecords2.visible = lblNoMedicalRecords2.includeInLayout = false;
	}
	
	if(medicalRecordsSearch.text != "") {
		lblSearchResultsMedRec.text = 'Search Results: "' + medicalRecordsSearch.text + '"';
		lblSearchResultsMedRec.visible = btnClearSearchMedRec.visible = true;
	}
	else lblSearchResultsMedRec.visible = btnClearSearchMedRec.visible = false;
}

private function filterSearchMedRed(item:Object):Boolean {
	var pattern:RegExp = new RegExp("[^]*"+medicalRecordsSearch.text+"[^]*", "i");
	var concatenatedNextSteps:String = "";
	if(item.nextSteps) {
		for(var i:uint = 0; i < item.nextSteps.length; i++) {
			concatenatedNextSteps += item.nextSteps[i].task;
		}
	}
	return pattern.test(item.name) || pattern.test(item.reason) || pattern.test(item.provider) || pattern.test(item.classification) || pattern.test(item.date) || pattern.test(item.inpdate) || pattern.test(concatenatedNextSteps);
}

private function clearSearchMedRec():void {
	medicalRecordsData.filterFunction = null;
	medicalRecordsData.refresh();
	medicalRecordsDataGrid.filterFunction = null;
	medicalRecordsDataGrid.refresh();
	medicalRecordsSearch.text = "Search medical records";
	lblSearchResultsMedRec.visible = btnClearSearchMedRec.visible = false;
	plotMedicalRecords.visible = plotMedicalRecords.includeInLayout = myTreeMedRec.visible = myTreeMedRec.includeInLayout = legendMedicalRecords.visible = legendMedicalRecords.includeInLayout = medRecDGHeader.visible = medRecDGHeader.includeInLayout = medRecDGLine.visible = medRecDGLine.includeInLayout = medicalRecordsList.visible = medicalRecordsList.includeInLayout = true;
	lblNoMedicalRecords1.visible = lblNoMedicalRecords1.includeInLayout = lblNoMedicalRecords2.visible = lblNoMedicalRecords2.includeInLayout = false;
}

public function handleRecommendation(recommendation:String):void {
	if(recommendation == 'Gentle Chair Yoga Class') {
		this.currentState = 'modCalendar';
		if(shouldAddInitialAppointments) onApplicationStart();
		requestClasses('yogaGentle');
		/*if(parentApplication.areMessageTabsCreated) {		//areMessageTabsCreated is a fix; if we call createNewMessage from here before the messages module has been created, then it messes up everything... so, the first time we just set it to true, and createNewMessage() is called from the messages module instead...
			var recipient:uint = type == "appointment" ? 1 : 2;
			parentApplication.createNewMessage(recipient);
			parentApplication.tabsMessages.selectedIndex = parentApplication.viewStackMessages.length - 2;
		}
		else parentApplication.areMessageTabsCreated = true;*/
	}
	else if(recommendation == 'Nutrition Workshop') {
		this.currentState = 'modCalendar';
		if(shouldAddInitialAppointments) onApplicationStart();
		requestClasses('hLifeWeight');
	}
}