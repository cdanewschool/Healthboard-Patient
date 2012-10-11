import components.vitalSigns.addTrackerWindow;
import components.vitalSigns.editGoalWindow;
import components.vitalSigns.recordVitalsWindow;

import mx.charts.ChartItem;
import mx.charts.events.ChartItemEvent;
import mx.charts.series.items.LineSeriesItem;
import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.ClassFactory;
import mx.graphics.IFill;
import mx.graphics.SolidColor;
import mx.managers.PopUpManager;

import spark.components.TitleWindow;

import util.DateUtil;

private function calcCommentsRowColor(item:Object, rowIndex:int, dataIndex:int, color:uint):uint {
	if(item.chartType == "comments" || item.chartType == "untrackable") return 0x000000;
	else return color;
}

public function get10digitDate(date:String):String {
	if(date.charAt(1) == '/') date = '0' + date;									// 3/4/2012
	if(date.charAt(4) == '/') date = date.substr(0,3) + '0' + date.substr(-6);		// 03/4/2012
	return date;
}

public function vitalSignsFillFunction(element:ChartItem, index:Number):IFill {
	var item:LineSeriesItem = LineSeriesItem(element);
	//if(item.currentState == 'rollOver') return colorImmunizationsDue;
	return (item.item.type == 'provider') ? chartStyles.colorVitalSignsProvider : chartStyles.colorVitalSignsPatient;
}

private function recordVitals():void {
	var myRecordVitals:recordVitalsWindow = recordVitalsWindow(PopUpManager.createPopUp(this, recordVitalsWindow) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myRecordVitals);
}

private function switchVitalView(index:uint):void {
	viewsVitalSigns.selectedIndex = index;
	if(index == 1) {
		btnVitalChart.setStyle("chromeColor", 0xB3B3B3);
		btnVitalList.setStyle("chromeColor", 0xFF931E);
	}
	else {
		btnVitalChart.setStyle("chromeColor", 0xFF931E);
		btnVitalList.setStyle("chromeColor", 0xB3B3B3);
	}
	
	if(index == 0) highlightSelectedVital('All');
	else if(index == 2) highlightSelectedVital('Weight');
	else if(index == 3) highlightSelectedVital('Blood Pressure');
}

private function weightChartRolloverEventHandler(event:ChartItemEvent):void {
	lblWeight.text = arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index].value;
	lblDate.text = lblDate2.text = DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index].date);
	lblWeightDiff.text = (event.hitData.chartItem.index == 0) ? '' : String(arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index].value - arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index - 1].value);
	lblDatePrev.text = lblDatePrev2.text = (event.hitData.chartItem.index == 0) ? '' : 'from ' + DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index - 1].date);
	lblWeightDiffUnits.visible = (event.hitData.chartItem.index != 0);
	lblBMIDiffUnits.visible = (event.hitData.chartItem.index != 0);
	imgWeightDiffPos.visible = imgWeightDiffPos.includeInLayout = Number(lblWeightDiff.text) < 0;
	imgWeightDiffNeg.visible = imgWeightDiffNeg.includeInLayout = Number(lblWeightDiff.text) > 0;
	lblBMI.text = String(int(((arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index].value * 703) / Math.pow(arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data[arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data.length - 1].value, 2))*10)/10);
	lblBMIDiff.text = (event.hitData.chartItem.index == 0) ? '' : String(int((int(((arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index].value * 703) / Math.pow(arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data[arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data.length - 1].value, 2))*10)/10 - int(((arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[event.hitData.chartItem.index - 1].value * 703) / Math.pow(arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data[arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data.length - 1].value, 2))*10)/10)*10)/10);
	imgBMIDiffPos.visible = imgBMIDiffPos.includeInLayout = Number(lblBMIDiff.text) < 0;
	imgBMIDiffNeg.visible = imgBMIDiffNeg.includeInLayout = Number(lblBMIDiff.text) > 0;
	myLineSeries.setStyle("itemRenderer",new ClassFactory(ASclasses.MyCircleItemRendererOverIndividual));
}
private function weightChartRolloutEventHandler(event:ChartItemEvent):void {
	lblWeight.text = arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 1].value;
	lblDate.text = lblDate2.text = DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 1].date);
	lblWeightDiff.text = String(arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 1].value - arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 2].value);
	lblDatePrev.text = lblDatePrev2.text = 'from ' + DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 2].date);
	lblWeightDiffUnits.visible = lblBMIDiffUnits.visible = true;
	imgWeightDiffPos.visible = imgWeightDiffPos.includeInLayout = Number(lblWeightDiff.text) < 0;
	imgWeightDiffNeg.visible = imgWeightDiffNeg.includeInLayout = Number(lblWeightDiff.text) > 0;
	lblBMI.text = String(int(((arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 1].value * 703) / Math.pow(arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data[arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data.length - 1].value, 2))*10)/10);
	lblBMIDiff.text = String(int((int(((arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 1].value * 703) / Math.pow(arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data[arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data.length - 1].value, 2))*10)/10 - int(((arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Weight')).chart[0].data.length - 2].value * 703) / Math.pow(arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data[arrVitalSigns[vitalIndices.indexOf('Height')].chart[0].data.length - 2].value, 2))*10)/10)*10)/10);
	imgBMIDiffPos.visible = imgBMIDiffPos.includeInLayout = Number(lblBMIDiff.text) < 0;
	imgBMIDiffNeg.visible = imgBMIDiffNeg.includeInLayout = Number(lblBMIDiff.text) > 0;
	myLineSeries.setStyle("itemRenderer",new ClassFactory(ASclasses.MyCircleItemRendererIndividual));
}

private function pressureChartRolloverEventHandler(event:ChartItemEvent):void {
	lblBloodPressure1.text = arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index].value;
	lblBloodPressure2.text = arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index].value2;
	lblDatePressure.text = DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index].date);
	lblSystolicDiff.text = (event.hitData.chartItem.index == 0) ? '' : String(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index].value - arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index - 1].value);
	lblDiastolicDiff.text = (event.hitData.chartItem.index == 0) ? '' : String(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index].value2 - arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index - 1].value2);
	lblDatePressurePrev.text = (event.hitData.chartItem.index == 0) ? '' : 'from ' + DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[event.hitData.chartItem.index - 1].date);
	lblPressureDiffUnits.visible = (event.hitData.chartItem.index != 0);
	lblDiffDash.visible = (event.hitData.chartItem.index != 0);
	imgSystolicDiffNeg.visible = imgSystolicDiffNeg.includeInLayout = Number(lblSystolicDiff.text) > 0;
	imgSystolicDiffPos.visible = imgSystolicDiffPos.includeInLayout = Number(lblSystolicDiff.text) < 0;
	imgDiastolicDiffNeg.visible = imgDiastolicDiffNeg.includeInLayout = Number(lblDiastolicDiff.text) > 0;
	imgDiastolicDiffPos.visible = imgDiastolicDiffPos.includeInLayout = Number(lblDiastolicDiff.text) < 0;
	myPressureLineSeries.setStyle("itemRenderer",new ClassFactory(ASclasses.MyCircleItemRendererOverIndividual));
	myPressureLineSeries2.setStyle("itemRenderer",new ClassFactory(ASclasses.MyCircleItemRendererOverIndividual));
}
private function pressureChartRolloutEventHandler(event:ChartItemEvent):void {
	lblBloodPressure1.text = arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 1].value;
	lblBloodPressure2.text = arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 1].value2;
	lblDatePressure.text = DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 1].date);
	lblSystolicDiff.text = String(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 1].value - arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 2].value);
	lblDiastolicDiff.text = String(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 1].value2 - arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 2].value2);
	lblDatePressurePrev.text = 'from ' + DateUtil.formatDateFromString(arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data[arrVitalSigns.getItemAt(vitalIndices.indexOf('Blood pressure')).chart[0].data.length - 2].date);
	lblPressureDiffUnits.visible = lblDiffDash.visible = true;	
	imgSystolicDiffNeg.visible = imgSystolicDiffNeg.includeInLayout = Number(lblSystolicDiff.text) > 0;
	imgSystolicDiffPos.visible = imgSystolicDiffPos.includeInLayout = Number(lblSystolicDiff.text) < 0;
	imgDiastolicDiffNeg.visible = imgDiastolicDiffNeg.includeInLayout = Number(lblDiastolicDiff.text) > 0;
	imgDiastolicDiffPos.visible = imgDiastolicDiffPos.includeInLayout = Number(lblDiastolicDiff.text) < 0;
	myPressureLineSeries.setStyle("itemRenderer",new ClassFactory(ASclasses.MyCircleItemRendererIndividual));
	myPressureLineSeries2.setStyle("itemRenderer",new ClassFactory(ASclasses.MyCircleItemRendererIndividual));
}

private function vitalsWeightChangeReference():void {
	if(dropDownVitalSignsWeightReference.selectedIndex == 0) {
		vitalsWeightLineChart.backgroundElements = vitalSignsWeightBackground;	
	}
	else {
		vitalsWeightLineChart.backgroundElements = vitalSignsWeightBackgroundB;
	}
}

private function vitalsPressureChangeReference():void {
	if(dropDownVitalSignsPressureReference.selectedIndex == 0) {
		vitalsPressureLineChart.backgroundElements = vitalSignsPressureSystolicBackground;
		myPressureLineSeries.alpha = myPressureExpectationSeries.alpha = 1;
		myPressureLineSeries2.alpha = myPressureExpectationSeries2.alpha = 0.25;
	}
	else {
		vitalsPressureLineChart.backgroundElements = vitalSignsPressureDiastolicBackground;
		myPressureLineSeries.alpha = myPressureExpectationSeries.alpha = 0.25;
		myPressureLineSeries2.alpha = myPressureExpectationSeries2.alpha = 1;
	}
}

private function editGoal():void {
	var myEditGoal:editGoalWindow = editGoalWindow(PopUpManager.createPopUp(this, editGoalWindow) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myEditGoal);
}

private function highlightSelectedVital(vital:String = "none"):void {
	btnVSAll.styleName = "messageFolderNotSelected";
	btnVSWeight.styleName = "messageFolderNotSelected";
	btnVSBloodPressure.styleName = "messageFolderNotSelected";
	if(vital == "All") btnVSAll.styleName = "messageFolderSelected";
	else if(vital == "Weight") btnVSWeight.styleName = "messageFolderSelected";
	else if(vital == "Blood Pressure") btnVSBloodPressure.styleName = "messageFolderSelected";
}

private function addTracker():void {
	var myAddTracker:addTrackerWindow = addTrackerWindow(PopUpManager.createPopUp(this, addTrackerWindow) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myAddTracker);
}

//MOVE TO SHARED ONCE THE VITAL SIGNS MODULE IS CREATED IN THE PROVIDER PORTAL
private function handleVitalsDateRange(range:String):void {
	if(range == '1w') {
		chartMin = new Date(controller.model.today.getTime() - 1000*60*60*24*7);	//new Date(2012,8,18);
		btnVital1m.selected = btnVital3m.selected = btnVital1y.selected = btnVital3y.selected = btnVitalAll.selected = btnVitalCustom.selected = false;
	}
	else if(range == '1m') {
		chartMin = new Date(controller.model.today.getTime() - 1000*60*60*24*30);	//new Date(2012,7,25);
		btnVital1w.selected = btnVital3m.selected = btnVital1y.selected = btnVital3y.selected = btnVitalAll.selected = btnVitalCustom.selected = false;
	}
	else if(range == '3m') {
		chartMin = new Date(controller.model.today.getTime() - 1000*60*60*24*91);	//new Date(2012,5,25);
		btnVital1w.selected = btnVital1m.selected = btnVital1y.selected = btnVital3y.selected = btnVitalAll.selected = btnVitalCustom.selected = false;
	}
	else if(range == '1y') {
		chartMin = new Date(controller.model.today.getTime() - 1000*60*60*24*365.24);	//new Date(2011,8,25);
		btnVital1w.selected = btnVital1m.selected = btnVital3m.selected = btnVital3y.selected = btnVitalAll.selected = btnVitalCustom.selected = false;
	}
	else if(range == '3y') {
		chartMin = new Date(controller.model.today.getTime() - 1000*60*60*24*1095.73);	//new Date(2009,8,25);
		btnVital1w.selected = btnVital1m.selected = btnVital3m.selected = btnVital1y.selected = btnVitalAll.selected = btnVitalCustom.selected = false;
	}
	else if(range == 'all') {
		chartMin = new Date(2011,7,26);
		btnVital1w.selected = btnVital1m.selected = btnVital3m.selected = btnVital1y.selected = btnVital3y.selected = btnVitalCustom.selected = false;
	}
}