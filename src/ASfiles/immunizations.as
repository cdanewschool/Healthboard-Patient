import ASclasses.MyCustomDataTip;

import components.immunizations.ImmunizationDetails;

import flash.display.CapsStyle;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.events.MouseEvent;

import mx.charts.ChartItem;
import mx.charts.DateTimeAxis;
import mx.charts.HitData;
import mx.charts.events.ChartItemEvent;
import mx.charts.series.items.PlotSeriesItem;
import mx.collections.ArrayCollection;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.graphics.IFill;
import mx.graphics.SolidColor;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import spark.events.IndexChangeEvent;

import styles.ChartStyles;

import util.ChartLabelFunctions;
import util.DateFormatters;

private function immunizationsFillFunction(element:ChartItem, index:Number):IFill {
	var c:SolidColor = chartStyles.colorImmunizationsDue1Month	//yellow
	var item:PlotSeriesItem = PlotSeriesItem(element);
	var immunizationDate:Date = new Date(item.xValue);		//new Date(item.xValue.substr(6),item.xValue.substr(0,2)-1,item.xValue.substr(3,2));
	var todayWithTime:Date = new Date();
	var today:Date = new Date(todayWithTime.getFullYear(),todayWithTime.getMonth(),todayWithTime.getDate());
	
	if(item.item.completed == true) {
		c = chartStyles.colorImmunizationsCompleted;		//gray
	}
	else if(immunizationDate.getTime() == today.getTime()) {
		c = chartStyles.colorImmunizationsToday;		//green
	}
	else if(immunizationDate.getTime() < today.getTime()) {
		c = chartStyles.colorImmunizationsDue;		//red
	}
	
	return c;
}

/**This function is basically identical to the preceding one.
 * It is used, however, by the itemRenderer component in the Data Grid showing the immunizations list.
 * The preceding one couldn't be used in this case, since the required parameters for that function weren't available in the itemRenderer component.
 */
public function myImmunizationsFillFunction(completed:Boolean, immunizationDateString:String):SolidColor {
	var c:SolidColor = chartStyles.colorImmunizationsDue1Month	//yellow
	var immunizationDate:Date = new Date(immunizationDateString);		//new Date(immunizationDateString.substr(6),Number(immunizationDateString.substr(0,2))-1,immunizationDateString.substr(3,2));
	var todayWithTime:Date = new Date();
	var today:Date = new Date(todayWithTime.getFullYear(),todayWithTime.getMonth(),todayWithTime.getDate());
	
	if(completed == true) {
		c = chartStyles.colorImmunizationsCompleted;		//gray
	}
	else if(immunizationDate.getTime() == today.getTime()) {
		c = chartStyles.colorImmunizationsToday;		//green
	}
	else if(immunizationDate.getTime() < today.getTime()) {
		c = chartStyles.colorImmunizationsDue;		//red
	}
	
	return c;
}

/**
 * Same as previous two, used by "ImmunizationDetails.mxml" and main DataGrid view to display Status
 */
public function getStatus(completed:Boolean, immunizationDateString:String):String {
	var c:String = "Due Within One Month"	//yellow
	var immunizationDate:Date = new Date(immunizationDateString);
	var todayWithTime:Date = new Date();
	var today:Date = new Date(todayWithTime.getFullYear(),todayWithTime.getMonth(),todayWithTime.getDate());
	
	if(completed == true) {
		c = "Completed";
	}
	else if(immunizationDate.getTime() == today.getTime()) {
		c = "Addressed Today for Immunizations Have Been Given";
	}
	else if(immunizationDate.getTime() < today.getTime()) {
		c = "Overdue";		//red
	}
	
	return c;
}

[Bindable] private var minDate:Date = new Date( "Dec 14 2011 01:03:54 AM");
[Bindable] private var maxDate:Date = new Date( "Dec 14 2012 01:03:54 AM");
private function immunizationsSetMinMax():void {
	hAxisImmunizations.minimum = minDate;	//new Date( "Oct 1 2010 01:03:54 AM");
	hAxisImmunizations.maximum = maxDate;	//new Date( "Oct 1 2011 01:03:54 AM");
	
	chartStyles.canvas.lineStyle(3,0x00ADEE,0.3,true,LineScaleMode.NORMAL,CapsStyle.ROUND,JointStyle.MITER,2);
	chartStyles.canvas.moveTo(DateFormatters.dateFormatterToday.format(new Date()),'Anthrax');		//canvas.moveTo(dateFormatterToday.format(new Date()),immunizationsCategories.length);
	chartStyles.canvas.lineTo(DateFormatters.dateFormatterToday.format(new Date()),'Yellow Fever');	//canvas.lineTo(dateFormatterToday.format(new Date()),0.05);
	
	/*canvas.lineStyle(1,0xFFFFFF,0.3,true,LineScaleMode.NORMAL,CapsStyle.ROUND,JointStyle.MITER,2);
	//canvas.moveTo(dateFormatterToday.format(new Date("Sep 30 2010 01:03:54 AM")),'Influenza');
	//canvas.lineTo(dateFormatterToday.format(new Date()),'Influenza');
	for(var i:uint = 0; i < immunizationsCategories.length; i++) {
	var minDatePlus1:Date = minDate;
	minDatePlus1.setDate(minDate.getDate() + 1);
	canvas.moveTo(this.dateFormatterToday.format(minDatePlus1),this.immunizationsCategories[i]);
	canvas.lineTo(this.dateFormatterToday.format(maxDate),this.immunizationsCategories[i]);
	}*/
}

private function handleImmDateRange(range:String):void {
	if(range == '1m') {
		minDate = new Date( "Jun 28 2012 01:03:54 AM");		//"Feb 28 2012 01:03:54 AM"
		maxDate = new Date( "Aug 4 2012 01:03:54 AM");		//"Apr 4 2012 01:03:54 AM"
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartMonth;
		chartStyles.immVerticalGridLine.alpha = 0;
		btnImm3m.selected = btnImm1y.selected = btnImm3y.selected = btnImm5y.selected = btnImm10y.selected = btnImmAll.selected = btnImmCustom.selected = false;
	}
	else if(range == '3m') {
		minDate = new Date( "Apr 28 2012 01:03:54 AM");		//"Jan 31 2012 01:03:54 AM"
		maxDate = new Date( "Aug 7 2012 01:03:54 AM");		//"May 31 2012 01:03:54 AM"
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartMonth;
		chartStyles.immVerticalGridLine.alpha = 0;
		btnImm1m.selected = btnImm1y.selected = btnImm3y.selected = btnImm5y.selected = btnImm10y.selected = btnImmAll.selected = btnImmCustom.selected = false;
	}
	else if(range == '1y') {
		minDate = new Date( "Dec 14 2011 01:03:54 AM");		//"Jul 14 2011 01:03:54 AM"
		maxDate = new Date( "Dec 14 2012 01:03:54 AM");		//"Jul 14 2012 01:03:54 AM"
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartMonth;
		chartStyles.immVerticalGridLine.alpha = 0;
		btnImm1m.selected = btnImm3m.selected = btnImm3y.selected = btnImm5y.selected = btnImm10y.selected = btnImmAll.selected = btnImmCustom.selected = false;
	}
	else if(range == '3y') {
		minDate = new Date( "Dec 4 2009 01:03:54 AM");		//"Sep 4 2009 01:03:54 AM"
		maxDate = new Date( "Feb 4 2013 01:03:54 AM");		//"Sep 4 2012 01:03:54 AM"
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartYear;
		chartStyles.immVerticalGridLine.alpha = 0.3;
		btnImm1m.selected = btnImm3m.selected = btnImm1y.selected = btnImm5y.selected = btnImm10y.selected = btnImmAll.selected = btnImmCustom.selected = false;
	}
	else if(range == '5y') {
		minDate = new Date( "Dec 4 2007 01:03:54 AM");		//"Jul 1 2007 01:03:54 AM"
		maxDate = new Date( "Mar 4 2013 01:03:54 AM");		//"Jul 1 2012 01:03:54 AM"
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartYear;
		chartStyles.immVerticalGridLine.alpha = 0.3;
		btnImm1m.selected = btnImm3m.selected = btnImm1y.selected = btnImm3y.selected = btnImm10y.selected = btnImmAll.selected = btnImmCustom.selected = false;
	}
	else if(range == '10y') {
		minDate = new Date( "Nov 4 2002 01:03:54 AM");		//"Aug 1 2002 01:03:54 AM"
		maxDate = new Date( "Apr 4 2013 01:03:54 AM");		//"Aug 1 2012 01:03:54 AM"
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartYear;
		chartStyles.immVerticalGridLine.alpha = 0.3;
		btnImm1m.selected = btnImm3y.selected = btnImm1y.selected = btnImm3y.selected = btnImm5y.selected = btnImmAll.selected = btnImmCustom.selected = false;
	}
	else if(range == 'all') {
		minDate = new Date( "Nov 4 2002 01:03:54 AM");
		maxDate = new Date( "Apr 4 2013 01:03:54 AM");
		hAxisImmunizations.labelFunction = ChartLabelFunctions.lblHAxisPlotChartYear;
		chartStyles.immVerticalGridLine.alpha = 0.3;
		btnImm1m.selected = btnImm3y.selected = btnImm1y.selected = btnImm3y.selected = btnImm5y.selected = btnImm10y.selected = btnImmCustom.selected = false;
	}
	hAxisImmunizations.minimum = minDate;
	hAxisImmunizations.maximum = maxDate;
	
	/*for(var i:uint = 0; i < immunizationsCategories.length; i++) {
	var minDatePlus1:Date = minDate;
	minDatePlus1.setDate(minDate.getDate() + 1);
	canvas.moveTo(this.dateFormatterToday.format(minDatePlus1),this.immunizationsCategories[i]);
	canvas.lineTo(this.dateFormatterToday.format(maxDate),this.immunizationsCategories[i]);
	}*/
}

private function switchImmunizationsView(index:uint):void {
	viewsImmunization.selectedIndex = index;
	if(index == 0) {
		btnImmunizationsChart.setStyle("chromeColor", 0xFF931E);
		btnImmunizationsList.setStyle("chromeColor", 0xB3B3B3);
	}
	else {
		btnImmunizationsChart.setStyle("chromeColor", 0xB3B3B3);
		btnImmunizationsList.setStyle("chromeColor", 0xFF931E);
	}
}

[Bindable] private var immunizationItemDrillDown:ArrayCollection = new ArrayCollection();
private function showImmunizationDetails(e:ChartItemEvent):void{
	viewImmunizationDetails(e.hitData.item);
	//this.immunizationItemDrillDown.source = e.hitData.item.details.source;
	//immunizationsDetails.visible = true;
}

public function showImmunizationDetailsAxis(imm:String):void {
	for(var i:uint = 0; i < immunizationsData.length; i++) {
		if(immunizationsData.getItemAt(i).name == imm) break;
	}
	PopUpManager.removePopUp(myChartPopup);		//remove existing popup (if any).
	viewImmunizationDetails(immunizationsData.getItemAt(i));
}

public var arrOpenTabsIM:Array = new Array();
public function viewImmunizationDetails(immunization:Object):void {
	var isImmunizationAlreadyOpen:Boolean = false;
	for(var j:uint = 0; j < arrOpenTabsIM.length; j++) {
		if(arrOpenTabsIM[j] == immunization) {
			isImmunizationAlreadyOpen = true;
			viewStackImmunizations.selectedIndex = j + 1;		//+1 because in arrOpenTabs we don't include the first tab
			break;
		}
	}				
	if(!isImmunizationAlreadyOpen) {
		var immunizationDetails:ImmunizationDetails = new ImmunizationDetails();
		immunizationDetails.immunizationData = immunization;
		viewStackImmunizations.addChild(immunizationDetails);
		tabsImmunizations.selectedIndex = viewStackImmunizations.length - 1;
		arrOpenTabsIM.push(immunization);
	}
}

private function lblImmunizationDetailsAge(item:Object, column:DataGridColumn):String {
	return item.lastGiven == '-' ? '-' : String(int(item.lastGiven.substr(6)) - 1965);
}

/*private function lblImmunizationDetailsNextDue(item:Object, column:DataGridColumn):String {
	return item.details[5].data1;
}
private function lblImmunizationDetailsSeries(item:Object, column:DataGridColumn):String {
	return item.details[1].data1;
}
private function lblImmunizationDetailsExpires(item:Object, column:DataGridColumn):String {
	return item.details[7].data1;
}
private function lblImmunizationDetailsLastEdit(item:Object, column:DataGridColumn):String {
	return item.details[0].data2;
}*/

private function applyCustomDataTipsImm():void {
	plotImmunizations.setStyle("dataTipRenderer",MyCustomDataTip);
}

private function dataTipsImmunizations(hd:HitData):String {
	/*var completed:String = hd.item.completed == true ? "Completed" : "Not completed";
	return "<b>" + hd.item.name + " immunization: " + hd.item.date + "</b><br><i>" + completed + ".</i><br><br>" + hd.item.description;*/
	var immunizationDate:Date = new Date(hd.item.date);
	var todayWithTime:Date = new Date();
	var today:Date = new Date(todayWithTime.getFullYear(),todayWithTime.getMonth(),todayWithTime.getDate());
	var status:String = hd.item.completed == true ? "Completed" : (immunizationDate.getTime() < today.getTime()) ? "Overdue" : "Due";
	return "<b>" + hd.item.name + "</b><br><i>Status: " + status + "<br>Due by: " + hd.item.date + "<br><br>Click to view immunization details</i>";
}

protected function checkImmunizationsRequired_clickHandler(event:IndexChangeEvent):void {
	//if(checkImmunizationsRequired.selected) {
	if(dropImmunizationsFilter.selectedIndex == 1) {
		for(var i:uint = 0; i < immunizationsData.length; i++) {
			if(immunizationsData[i].required == false) {
				immunizationsData.removeItemAt(i);
				i--;
			}
		}
		
		//The following is done so that once we check the "Required Only" box, not only we hide the "not required points", but also remove the entire "row" or "category" for the non-required immunization. Therefore, we reset immunizationsCategories.
		immunizationsCategories = new Array();
		for(var j:uint = 0; j < immunizationsData.length; j++) {
			if(immunizationsCategories.indexOf(immunizationsData[j].name) == -1) immunizationsCategories.push(immunizationsData[j].name);
		}
	}
	else {
		immunizationsXMLdata.send();
	}
}

public function getLabelDataTip(name:String):String {
	for(var i:uint = 0; i < immunizationsData.length; i++) {
		if(immunizationsData[i].name == name) return immunizationsData[i].description;
	}
	return '';
}
