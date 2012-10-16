/**
 * NOTE: This file has been deprecated, and has been replaced by NutritionController, NutritionModel and NutritionModule.
 */
import ASclasses.Constants;

import components.nutrition.FoodJournalToolTip;
import components.nutrition.FoodPlanToolTip;
import components.nutrition.downloadWorksheetWindow;
import components.nutrition.help;
import components.nutrition.tips;

import mx.charts.ChartItem;
import mx.charts.series.items.BarSeriesItem;
import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.events.ToolTipEvent;
import mx.graphics.GradientEntry;
import mx.graphics.IFill;
import mx.graphics.LinearGradient;
import mx.graphics.SolidColor;
import mx.managers.PopUpManager;

import util.DateUtil;

public static const millisecondsPerDay:int = 1000 * 60 * 60 * 24;
private var today:Date = new Date();	//TODO: replace with value on app model once this code is in it's own module
private var currentDay:Date;
private var thisSunday:Date = new Date(today.getTime() - today.getDay() * millisecondsPerDay);
private var thisSaturday:Date = new Date(thisSunday.getTime() + 6 * millisecondsPerDay);
private var currentSunday:Date;
private var currentSaturday:Date;
[Bindable] private var currentDailyPlate:uint = 0;
[Bindable] private var currentWeeklyPlate:uint = 1;
[Bindable] private var currentMonthlyPlate:uint = 2;
[Bindable] private var currentDayDiff:int = 0;
[Bindable] private var currentWeekDiff:int = 0;
[Bindable] private var currentMonthDiff:int = 0;
[Bindable] private var currentMonth:Date;
//[Bindable] private var adjustedCurrentMonthDiff:int;
[Bindable] private var currentYearDiff:int = 0;

public var arrSavedMeals:Array = new Array(
	new ArrayCollection(['Cereal','Yogurt with cereal bar','Orange juice']),
	new ArrayCollection(['Gnocchi with sausage','Tuna Salad','Turkey Sandwich']),
	new ArrayCollection(['Cereal Bar','Ham and cheese sandwich','Nuts','Peanut butter and jelly']),
	new ArrayCollection(['Spinach Lasagna','Fajitas (Chicken with Onions, Green Pepper)','Chipotle Veggie Burrito','Tuna Noodle Casserole'])
);

[Bindable] private var hasMealBeenSubmitted:Boolean = false;
[Bindable] private var mealType:String;
[Bindable] private var glassesTaken:uint = 0;

[Bindable] [Embed("images/vitalSignsCommentPatient.png")] public var iconComment:Class;

[Bindable] [Embed("images/nutritionPlateEmpty.png")] public var plateEmpty:Class;
[Bindable] [Embed("images/nutritionPlateFull.png")] public var plateFull:Class;
[Bindable] [Embed("images/nutritionPlatePartial.png")] public var platePartial:Class;
[Bindable] [Embed("images/nutritionPlateAlternative.png")] public var plateAlternative:Class;
[Bindable] [Embed("images/nutritionSodiumEmpty.png")] public var sodiumEmpty:Class;
[Bindable] [Embed("images/nutritionSodiumPartial.png")] public var sodiumPartial:Class;
//[Bindable] [Embed("images/nutritionSodiumFull.png")] public var sodiumFull:Class;
[Bindable] [Embed("images/nutritionFatsOilsEmpty.png")] public var fatsOilsEmpty:Class;
//[Bindable] [Embed("images/nutritionFatsOilsPartial.png")] public var fatsOilsPartial:Class;
[Bindable] [Embed("images/nutritionSugarsEmpty.png")] public var sugarsEmpty:Class;
[Bindable] [Embed("images/nutritionSugarsPartial.png")] public var sugarsPartial:Class;
//[Bindable] [Embed("images/nutritionSugarsFull.png")] public var sugarsFull:Class;
[Bindable] [Embed("images/nutritionAlcoholEmpty.png")] public var alcoholEmpty:Class;
//[Bindable] [Embed("images/nutritionAlcoholFull.png")] public var alcoholFull:Class;

[Bindable] [Embed('images/nutritionFoodJournalEmpty.png')] public var bigPlateEmpty:Class;
[Bindable] [Embed('images/nutritionFoodJournal.png')] public var bigPlatePartial:Class;
[Bindable] [Embed('images/nutritionFoodJournalFull.png')] public var bigPlateFull:Class;
[Bindable] [Embed('images/nutritionFoodJournalAlmostFull.png')] public var bigPlateAlmostFull:Class;
[Bindable] [Embed("images/nutritionBigSodiumEmpty.png")] public var bigSodiumEmpty:Class;
[Bindable] [Embed("images/nutritionBigSodiumPartial.png")] public var bigSodiumPartial:Class;
[Bindable] [Embed("images/nutritionBigSodiumFull.png")] public var bigSodiumFull:Class;
[Bindable] [Embed("images/nutritionBigSodiumFullRed.png")] public var bigSodiumFullRed:Class;
[Bindable] [Embed("images/nutritionBigFatsOilsEmpty.png")] public var bigFatsOilsEmpty:Class;
[Bindable] [Embed("images/nutritionBigFatsOilsPartial.png")] public var bigFatsOilsPartial:Class;
[Bindable] [Embed("images/nutritionBigFatsOilsFull.png")] public var bigFatsOilsFull:Class;
[Bindable] [Embed("images/nutritionBigAlcoholEmpty.png")] public var bigAlcoholEmpty:Class;
[Bindable] [Embed("images/nutritionBigAlcoholPartial.png")] public var bigAlcoholPartial:Class;
[Bindable] [Embed("images/nutritionBigAlcoholFull.png")] public var bigAlcoholFull:Class;
[Bindable] [Embed("images/nutritionBigWaterEmpty.png")] public var bigWaterEmpty:Class;
[Bindable] [Embed("images/nutritionBigWaterPartial.png")] public var bigWaterPartial:Class;
[Bindable] [Embed("images/nutritionBigWaterFull.png")] public var bigWaterFull:Class;
[Bindable] [Embed("images/nutritionBigWaterVeryFull.png")] public var bigWaterVeryFull:Class;

[Bindable] [Embed("images/nutritionPlateEmptyWidget.png")] public var plateEmptyWidget:Class;
//[Bindable] [Embed("images/nutritionPlateFullWidget.png")] public var plateFullWidget:Class;	//(moved to SHARED)
[Bindable] [Embed("images/nutritionPlatePartialWidget.png")] public var platePartialWidget:Class;

[Bindable] private var arrNutSummaryCalories:ArrayCollection = new ArrayCollection([
	{type: "calories", calories: 0, goal: 1600, caloriesFromExtras: 0}
]);
[Bindable] private var arrNutDailyCaloriesAlt1:ArrayCollection = new ArrayCollection([
	{type: "calories", calories: 1550, goal: 1600, caloriesFromExtras: 450}
]);
[Bindable] private var arrNutDailyCaloriesAlt2:ArrayCollection = new ArrayCollection([
	{type: "calories", calories: 1700, goal: 1600, caloriesFromExtras: 515}
]);

[Bindable] private var arrNutWeeklyCalories:ArrayCollection = new ArrayCollection([
	{day: 'Sat', calories: 0, limit: 2000},
	{day: 'Fri', calories: 490, limit: 2000},
	{day: 'Thu', calories: 1970, limit: 2000},
	{day: 'Wed', calories: 1900, limit: 2000},
	{day: 'Tue', calories: 2150, limit: 2000},
	{day: 'Mon', calories: 1900, limit: 2000},
	{day: 'Sun', calories: 2000, limit: 2000}
]);

[Bindable] private var arrNutWeeklyCaloriesAlt1:ArrayCollection = new ArrayCollection([
	{day: 'Sat', calories: 1900, limit: 2000},
	{day: 'Fri', calories: 1600, limit: 2000},
	{day: 'Thu', calories: 2150, limit: 2000},
	{day: 'Wed', calories: 1900, limit: 2000},
	{day: 'Tue', calories: 1800, limit: 2000},
	{day: 'Mon', calories: 1800, limit: 2000},
	{day: 'Sun', calories: 1900, limit: 2000}
]);

[Bindable] private var arrNutWeeklyCaloriesAlt2:ArrayCollection = new ArrayCollection([
	{day: 'Sat', calories: 1700, limit: 2000},
	{day: 'Fri', calories: 2000, limit: 2000},
	{day: 'Thu', calories: 2100, limit: 2000},
	{day: 'Wed', calories: 1800, limit: 2000},
	{day: 'Tue', calories: 1750, limit: 2000},
	{day: 'Mon', calories: 1900, limit: 2000},
	{day: 'Sun', calories: 2200, limit: 2000}
]);

[Bindable] private var arrNutDailyCaloriesCurrent:ArrayCollection = arrNutSummaryCalories;

[Bindable] private var arrNutWeeklyCaloriesCurrent:ArrayCollection = arrNutWeeklyCalories;

[Bindable] private var arrNutMonthlyCalories:ArrayCollection = new ArrayCollection();

private var arrMonthlyCalories1:Array = new Array(1900,1970,2000,1900,2150,1800,2000,1900,2050,1750,2000,1900,1750,1800,2100,2000,1900,2000,1800,1800,1900,2150,1600,1900,1700,2000,1650,1800,2200,475);
private var arrMonthlyCalories2:Array = new Array(2000,1800,1900,1600,1700,1700,2100,1800,1900,2000,2000,2050,1750,1900,2100,2150,2000,2100,1800,1600,1800,1900,2000,1900,2150,1800,1600,2000,2150,1900);
private var arrMonthlyCalories3:Array = new Array(1900,2000,1650,1750,1900,2150,2050,2000,2150,1950,2100,2000,1800,1850,1800,1900,1600,1650,1600,1750,1800,1750,1600,1700,1900,2000,2000,2000,2100,1900);

private function avg(values:Array):int {
	var sum:int = 0;
	for(var i:uint = 0; i < values.length; i++) {
		sum += values[i];
	}
	return Math.round(sum/values.length);
}

[Bindable] public var nutritionNotes:ArrayCollection = new ArrayCollection([
	{note: "Try to avoid any salty food to decrease sodium.", completed:false, removed:false, recommendation:"Nutrition Workshop", date:"17:22, October 7, 2011"},
	{note: "Start the day with a whole grain cereal – wheat flakes, toasted O’s, or oatmeal are some examples.", completed:false, removed:false, recommendation:"Set a Reminder", date:"17:23, October 7, 2011"}
]);

[Bindable] public var nutritionMeals:ArrayCollection = new ArrayCollection([
	{meal: "1) 3/4 cub bran flakes cereal:\n     1 medium banana; and\n     1 cup low-fat milk."},
	{meal: "2) 1 slice whole wheat bread;\n     1tsp soft (tub) margarine; and\n     1 cup orange juice"},
	{meal: "3) 1 slice French toast; whole grain:\n     1 medium egg (for French toast);\n     1 teaspoon oil."}
]);

private function showTip():void {
	var myTipWindow:tips = tips(PopUpManager.createPopUp(this, tips) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myTipWindow);
}

private function updateNutritionDatesDay(set:String):void {
	if(set == 'today') {
		arrNutDailyCaloriesCurrent = arrNutSummaryCalories;
		txtMyPlateSubtext.text = "Today so far";
		lblWhatIHaveEaten.text = "What I Have Eaten Today";
	}
	else if(set == 'alt1') {
		arrNutDailyCaloriesCurrent = arrNutDailyCaloriesAlt1;
		txtMyPlateSubtext.text = "This day";
		lblWhatIHaveEaten.text = "What I Have Eaten This Day";
	}
	else if(set == 'alt2') {
		arrNutDailyCaloriesCurrent = arrNutDailyCaloriesAlt2;
		txtMyPlateSubtext.text = "This day";
		lblWhatIHaveEaten.text = "What I Have Eaten This Day";
	}
	
	arrNutDailyCaloriesCurrent.refresh();
	
	if(arrNutDailyCaloriesCurrent.getItemAt(0).caloriesFromExtras > 500) {
		nutCaloriesXaxisMaximumCurrent = 600;
		nutLabelsCurrent = NUTLABELS600;
		if(set == 'today') {
			nutCaloriesXaxisMaximumToday = 600;
			nutLabelsToday = NUTLABELS600;
		}
	}
	else {
		nutCaloriesXaxisMaximumCurrent = 500;
		nutLabelsCurrent = NUTLABELS500;
		if(set == 'today') {
			nutCaloriesXaxisMaximumToday = 500;
			nutLabelsToday = NUTLABELS500;
		}
	}
}

private function updateNutritionDatesWeek(set:String):void {
	if(set == 'thisWeek') arrNutWeeklyCaloriesCurrent = arrNutWeeklyCalories;
	else if(set == 'alt1') arrNutWeeklyCaloriesCurrent = arrNutWeeklyCaloriesAlt1;
	else if(set == 'alt2') arrNutWeeklyCaloriesCurrent = arrNutWeeklyCaloriesAlt2;
	
	arrNutWeeklyCaloriesCurrent.refresh();
	lblNutWeeklyAvgValue.text = String(avg(new Array(arrNutWeeklyCaloriesCurrent.getItemAt(0).calories,arrNutWeeklyCaloriesCurrent.getItemAt(1).calories,arrNutWeeklyCaloriesCurrent.getItemAt(2).calories,arrNutWeeklyCaloriesCurrent.getItemAt(3).calories,arrNutWeeklyCaloriesCurrent.getItemAt(4).calories,arrNutWeeklyCaloriesCurrent.getItemAt(5).calories,arrNutWeeklyCaloriesCurrent.getItemAt(6).calories)));
}

private function updateNutritionDatesMonth(set:String):void {
	arrNutMonthlyCalories = new ArrayCollection();
	var obj:Object;
	if(set == 'thisMonth') {
		for(var i:uint = 0; i < 30; i++) {
			//obj = new Object();
			obj = {day:(today.getMonth()+1) + '/' + (today.getDate()-(30 - i)) + '/' + today.getFullYear(), calories:arrMonthlyCalories1[i], goal:2000};
			//arrNutMonthlyCalories.getItemAt(i).day = (today.getMonth()+1) + '/' + (today.getDate()-(arrNutMonthlyCalories.length - i)) + '/' + today.getFullYear();
			//arrNutMonthlyCalories.getItemAt(i).calories = arrMonthlyCalories1[i];
			//arrNutMonthlyCalories.getItemAt(i).goal = 2000;
			arrNutMonthlyCalories.addItem(obj);
		}
		lblNutMonthlyAvgValue.text = String(avg(arrMonthlyCalories1));
	}
	else if(set == 'alt1') {
		for(var j:uint = 0; j < 30; j++) {
			obj = {day:(currentMonth.getMonth()+1) + '/' + (j+1) + '/' + currentMonth.getFullYear(), calories:arrMonthlyCalories2[j], goal:2000};
			//arrNutMonthlyCalories.getItemAt(j).day = (currentMonth.getMonth()+1) + '/' + (j+1) + '/' + currentMonth.getFullYear();
			//arrNutMonthlyCalories.getItemAt(j).calories = arrMonthlyCalories2[j];
			//arrNutMonthlyCalories.getItemAt(j).goal = 2000;
			arrNutMonthlyCalories.addItem(obj);
		}
		lblNutMonthlyAvgValue.text = String(avg(arrMonthlyCalories2));
	}
	else if(set == 'alt2') {
		for(var k:uint = 0; k < 30; k++) {
			obj = {day:(currentMonth.getMonth()+1) + '/' + (k+1) + '/' + currentMonth.getFullYear(), calories:arrMonthlyCalories3[k], goal:2000};
			//arrNutMonthlyCalories.getItemAt(k).day = (currentMonth.getMonth()+1) + '/' + (k+1) + '/' + currentMonth.getFullYear();
			//arrNutMonthlyCalories.getItemAt(k).calories = arrMonthlyCalories3[k];
			//arrNutMonthlyCalories.getItemAt(k).goal = 2000;
			arrNutMonthlyCalories.addItem(obj);
		}
		lblNutMonthlyAvgValue.text = String(avg(arrMonthlyCalories3));
	}
	arrNutMonthlyCalories.refresh();
}

private function showNutritionHelp():void {
	var myHelpWindow:help = help(PopUpManager.createPopUp(this, help) as spark.components.TitleWindow);
	myHelpWindow.viewStackHelp.selectedIndex = 3;
	PopUpManager.centerPopUp(myHelpWindow);
}

[Bindable] private var nutCaloriesXaxisMaximumToday:int = 500;
[Bindable] private var nutCaloriesXaxisMaximumCurrent:int = 500;
private const NUTLABELS500:String = "0                  100                200                300                400                500";
private const NUTLABELS600:String = "0              100            200            300            400            500            600";
[Bindable] private var nutLabelsToday:String = NUTLABELS500;
[Bindable] private var nutLabelsCurrent:String = NUTLABELS500;

private function handleNutritionMealEntry():void {
	hasMealBeenSubmitted = true;
	if(dropDownNutritionMealType.selectedIndex == 1 || dropDownNutritionMealType.selectedIndex == 3) {
		mealType = 'full';
		arrNutSummaryCalories.getItemAt(0).calories = 1700;
		arrNutSummaryCalories.getItemAt(0).caloriesFromExtras = 515;
		nutCaloriesXaxisMaximumToday = 600;
		nutLabelsToday = NUTLABELS600;
		if(currentDayDiff == 0) {
			nutCaloriesXaxisMaximumCurrent = 600;
			nutLabelsCurrent = NUTLABELS600;
		}
	}
	else {
		mealType = 'partial';
		arrNutSummaryCalories.getItemAt(0).calories = 532;
		arrNutSummaryCalories.getItemAt(0).caloriesFromExtras = 230;
		nutCaloriesXaxisMaximumToday = 500;
		nutLabelsToday = NUTLABELS500;
		if(currentDayDiff == 0) {
			nutCaloriesXaxisMaximumCurrent = 500;
			nutLabelsCurrent = NUTLABELS500;
		}
	}
	arrNutSummaryCalories.refresh();
	arrNutDailyCaloriesCurrent.refresh();
	if(nutComments.text != 'Enter when, where, and why you had the meal.' && nutComments.text != '') btnNutReadComment.visible = true;
	
	var now:Date = new Date();
	arrNutritionFoodJournal.addItem({meal:dropDownNutritionMealType.selectedItem, portion:numPortion.value + ' ' + nutritionPortionTypes.selectedItem, ingredients:(nutritionFoodSearch.text != 'Search' && nutritionFoodSearch.text != '') ? nutritionFoodSearch.text : dropDownNutritionSavedMeal.selectedItem, calories:123, date:DateUtil.get10DigitDate((now.getMonth()+1)+'/'+now.DateUtil.formatDateFromString()+'/'+now.getFullYear()), comments:(nutComments.text == 'Enter when, where, and why you had the meal.') ? '' : nutComments.text});
	nutritionJournal.rowCount++;
	nutritionJournal.rowCount--;		//this is a quick trick to get nutritionJournal.rowCount to refresh
	
	clearForm();
}

private function clearForm():void {
	dropDownNutritionMealType.selectedIndex = 0;
	dropDownNutritionSavedMeal.selectedIndex = -1;
	nutritionFoodSearch.text = "Search";
	numPortion.value = 1;
	nutritionPortionTypes.selectedIndex = 0;
	nutComments.text = "Enter when, where, and why you had the meal.";
}

/*private function nutCaloriesFillFunction(element:ChartItem, index:Number):IFill {
var item:BarSeriesItem = BarSeriesItem(element);

var ge1:GradientEntry = new GradientEntry(0xC2E1DF, 0);
var ge2:GradientEntry = new GradientEntry(0x51B6B2, .5);
var ge3:GradientEntry = new GradientEntry(0x6FD2B2, 1);	
var lgBlue:LinearGradient = new LinearGradient();
lgBlue.entries = [ge1, ge2, ge3];

var ge4:GradientEntry = new GradientEntry(0xFFFF9F, 0);
var ge5:GradientEntry = new GradientEntry(0xFFC500, .5);
var ge6:GradientEntry = new GradientEntry(0xF5FFB2, 1);	
var lgYellow:LinearGradient = new LinearGradient();
lgYellow.entries = [ge4, ge5, ge6];


myChart.setStyle("fill", lg1);     


//Use the yNumber properties rather than the yValue properties	because the conversion to a Number is already done for you. As a result, you do not have to cast them to a Number, which would be less efficient. 

var currentCalories:Number = nutCaloriesSeries.items[index].yNumber;

if (currentCalories >= 1600) {
return c; 
} else if (diff < 0) {
// Sales person did not meet their goal.
c.color = 0xFF0000;
c.alpha = 1;
}

return c;

} */

private var ge1:GradientEntry = new GradientEntry(0xC2E1DF, 0);
private var ge2:GradientEntry = new GradientEntry(0x51B6B2, .5);
private var ge3:GradientEntry = new GradientEntry(0x6FD2B2, 1);	
private var lgBlue:LinearGradient = new LinearGradient();
private var ge4:GradientEntry = new GradientEntry(0xF6AF95, 0);
private var ge5:GradientEntry = new GradientEntry(0xB71918, .5);
private var ge6:GradientEntry = new GradientEntry(0xF6A763, 1);	
private var lgRed:LinearGradient = new LinearGradient();
private function initFills():void {
	lgBlue.entries = [ge1, ge2, ge3];
	lgBlue.rotation = 90;
	lgRed.entries = [ge4, ge5, ge6];
	lgRed.rotation = 90;
}

private function nutCaloriesFromExtrasFillFunction(element:ChartItem, index:Number):IFill {
	return nutCaloriesFromExtrasSeries.items[index].xNumber <= 500 ? lgBlue : lgRed;
}

private function nutJournalCaloriesFromExtrasFillFunction(element:ChartItem, index:Number):IFill {
	return nutJournalCaloriesFromExtrasSeries.items[index].xNumber <= 500 ? lgBlue : lgRed;
}

private function nutCaloriesFillFunction(element:ChartItem, index:Number):IFill {
	var transparent:SolidColor = new SolidColor(0x000000,0);	
	//return nutJourWeeklyCalExcessSeries.items[index].xNumber <= 2000 ? transparent : lgBlue;
	//return dummy.items[index].xNumber <= 2000 ? transparent : lgBlue;
	return arrNutWeeklyCaloriesCurrent.getItemAt(index).calories <= 2000 ? transparent : lgBlue;
	
}

private function nutCaloriesExcessFillFunction(element:ChartItem, index:Number):IFill {
	return nutJourWeeklyCalExcessSeries.items[index].xNumber <= 2000 ? lgBlue : lgRed;
}

private function createCustomTip(title:String, body:String, event:ToolTipEvent):void {
	var myToolTip:FoodPlanToolTip = new FoodPlanToolTip();
	//myToolTip.title = title;
	//myToolTip.bodyText = body;
	event.toolTip = myToolTip;
}

public function createCustomTipJournal(event:ToolTipEvent):void {
	var myToolTip:FoodJournalToolTip = new FoodJournalToolTip();
	event.toolTip = myToolTip;
}

private function downloadWorksheet():void {
	var myDownloadWorksheet:downloadWorksheetWindow = downloadWorksheetWindow(PopUpManager.createPopUp(this, downloadWorksheetWindow) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myDownloadWorksheet);
}

[Bindable] public var arrNutritionFoodJournal:ArrayCollection = new ArrayCollection([
	{meal:'Breakfast', portion:'1 piece', ingredients:'Spinach quiche', calories:342, date: DateUtil.get10DigitDate((today.getMonth()+1)+'/'+today.getDate()+'/'+today.getFullYear()), comments:''},
	{meal:'Dinner', portion:'1 plate', ingredients:'Spaghetti and meatballs', calories:450, date: DateUtil.get10DigitDate((today.getMonth()+1)+'/'+today.getDate()+'/'+today.getFullYear()), comments:'I ate too much. Felt like I was having a heart attack!'}
]);//{meal:'Breakfast', portion:'1 bowl', ingredients:'Cereal', calories:105, date: DateUtil.get10DigitDate((today.getMonth()+1)+'/'+today.getDate()+'/'+today.getFullYear()), comments:''},
//{meal:'Breakfast', portion:'2 slices', ingredients:'Canadian bacon', calories:85, date: DateUtil.get10DigitDate((today.getMonth()+1)+'/'+today.getDate()+'/'+today.getFullYear()), comments:'Thin cut canadian bacon, lightly smoked.'},

private function handleNutritionDateRange(range:String):void {	
	if(range == '1d') {
		viewsNutritionJournal.selectedIndex = 0;
		btnNut1wk.selected = btnNut1mo.selected = btnNut3mo.selected = btnNutAll.selected = btnNutCustom.selected = false;
		txtMyPlateSubtext.text = currentDayDiff == 0 ? "Today so far" : "This day";
		showJournalPlate(currentDailyPlate);
		showCurrentDay();	//nutJournalDate.text = DateUtil.formatDateFromString((today.getMonth()+1)+'/'+today.getDate()+'/'+today.getFullYear());
		lblWhatIHaveEaten.text = currentDayDiff == 0 ? "What I Have Eaten Today" : "What I Have Eaten This Day";
	}
	else if(range == '1wk') {
		viewsNutritionJournal.selectedIndex = 1;
		btnNut1d.selected = btnNut1mo.selected = btnNut3mo.selected = btnNutAll.selected = btnNutCustom.selected = false;
		txtMyPlateSubtext.text = "Daily average";
		showJournalPlate(currentWeeklyPlate);
		showCurrentWeek();
		lblWhatIHaveEaten.text = "What I Have Eaten This Week";
	}
	else if(range == '1mo') {
		viewsNutritionJournal.selectedIndex = 2;
		btnNut1d.selected = btnNut1wk.selected = btnNut3mo.selected = btnNutAll.selected = btnNutCustom.selected = false;
		txtMyPlateSubtext.text = "Daily average";
		showJournalPlate(currentMonthlyPlate);
		showCurrentMonth();
		lblWhatIHaveEaten.text = "What I Have Eaten This Month";
	}
}

private function nutNavigateDate(direction:String):void {
	if(viewsNutritionJournal.selectedIndex == 0) {		//if view == DAILY
		if(direction == 'prev') currentDayDiff--;
		else currentDayDiff++;
		
		currentDailyPlate = (currentDayDiff == 0) ? 0 : (currentDailyPlate == 1) ? 2 : 1;
		showJournalPlate(currentDailyPlate);
		showCurrentDay();
		
		if(currentDayDiff == 0) updateNutritionDatesDay('today');
		else if(currentDailyPlate == 1) updateNutritionDatesDay('alt1');
		else updateNutritionDatesDay('alt2');
	}
	else if(viewsNutritionJournal.selectedIndex == 1) {		//if view == WEEKLY
		if(direction == 'prev') currentWeekDiff--;
		else currentWeekDiff++;
		
		currentWeeklyPlate = (currentWeeklyPlate == 1) ? 2 : 1;
		showJournalPlate(currentWeeklyPlate);
		showCurrentWeek();
		
		if(currentWeekDiff == 0) updateNutritionDatesWeek('thisWeek');
		else if(currentWeeklyPlate == 1) updateNutritionDatesWeek('alt1');
		else updateNutritionDatesWeek('alt2');
	}
	else {												//if view == MONTHLY
		if(direction == 'prev') currentMonthDiff--;
		else currentMonthDiff++;
		
		currentMonthlyPlate = (currentMonthlyPlate == 1) ? 2 : 1;
		showJournalPlate(currentMonthlyPlate);
		showCurrentMonth();
		
		if(currentMonthDiff == 0) updateNutritionDatesMonth('thisMonth');
		else if(currentMonthlyPlate == 1) updateNutritionDatesMonth('alt1');
		else updateNutritionDatesMonth('alt2');
	}
}

private function showJournalPlate(plate:uint):void {
	if(plate == 0) {		//today's intake
		imgNutJournalMyPlate.source = !hasMealBeenSubmitted ? bigPlateEmpty : mealType == 'full' ? bigPlateFull : bigPlatePartial;
		imgNutJournalSodium.source = !hasMealBeenSubmitted ? bigSodiumEmpty : mealType == 'full' ? bigSodiumFullRed : bigSodiumPartial;
		lblNutJournalSodium.text = !hasMealBeenSubmitted ? '0 mg.' : mealType == 'full' ? '2,000 mg.' : '600 mg.';
		imgNutJournalFatsOils.source = !hasMealBeenSubmitted ? bigFatsOilsEmpty : mealType == 'full' ? bigFatsOilsFull : bigFatsOilsPartial;
		lblNutJournalFatsOils.text = !hasMealBeenSubmitted ? '0 servings' : mealType == 'full' ? '2 - 3\nservings' : '1 serving';
		imgNutJournalSugars.source = !hasMealBeenSubmitted ? sugarsEmpty : mealType == 'full' ? sugarsFull : sugarsPartial;
		lblNutJournalSugars.text = !hasMealBeenSubmitted ? '0 servings' : mealType == 'full' ? '2 - 3\nservings' : '1 serving';
		imgNutJournalAlcohol.source = !hasMealBeenSubmitted ? bigAlcoholEmpty : mealType == 'full' ? bigAlcoholFull : bigAlcoholPartial;
		lblNutJournalAlcohol.text= !hasMealBeenSubmitted ? '0 drinks' : mealType == 'full' ? 'more than\n3 drinks' : 'less than\n2 drinks';
		imgNutJournalWater.source = glassesTaken == 0 ? bigWaterEmpty : glassesTaken == 8 ? bigWaterVeryFull : glassesTaken > 4 ? bigWaterFull : bigWaterPartial;
		lblNutJournalWater.text = glassesTaken + ' cups';
	}
	else if(plate == 1) {		//alternative intake 1
		imgNutJournalMyPlate.source = bigPlateAlmostFull;
		imgNutJournalSodium.source = bigSodiumFull;
		lblNutJournalSodium.text = '1,800 mg.';
		imgNutJournalFatsOils.source = bigFatsOilsFull;
		lblNutJournalFatsOils.text = '2 - 3\nservings';
		imgNutJournalSugars.source = sugarsFull;
		lblNutJournalSugars.text = '2 - 3\nservings';
		imgNutJournalAlcohol.source = bigAlcoholPartial;
		lblNutJournalAlcohol.text= 'less than\n2 drinks';
		imgNutJournalWater.source = bigWaterVeryFull;
		lblNutJournalWater.text = '8+ cups';		
	}
	else {			//alternative intake 2
		imgNutJournalMyPlate.source = bigPlateFull;
		imgNutJournalSodium.source = bigSodiumFullRed;
		lblNutJournalSodium.text = '2,000 mg.';
		imgNutJournalFatsOils.source = bigFatsOilsFull;
		lblNutJournalFatsOils.text = '2 - 3\nservings';
		imgNutJournalSugars.source = sugarsFull;
		lblNutJournalSugars.text = '2 - 3\nservings';
		imgNutJournalAlcohol.source = bigAlcoholFull;
		lblNutJournalAlcohol.text= 'more than\n3 drinks';
		imgNutJournalWater.source = bigWaterFull;
		lblNutJournalWater.text = '7 cups';		
	}
}

private function showCurrentDay():void {
	currentDay = new Date(today.getTime() + currentDayDiff*millisecondsPerDay);
	nutJournalDate.text = DateUtil.formatDateFromString((currentDay.getMonth()+1)+'/'+currentDay.DateUtil.formatDateFromString()+'/'+currentDay.getFullYear());
}

private function showCurrentWeek():void {
	currentSunday = new Date(thisSunday.getTime() + currentWeekDiff * (7 * millisecondsPerDay));
	currentSaturday = new Date(thisSaturday.getTime() + currentWeekDiff * (7 * millisecondsPerDay));
	nutJournalDate.text = DateUtil.formatDateFromString((currentSunday.getMonth()+1)+'/'+currentSunday.DateUtil.formatDateFromString()+'/'+currentSunday.getFullYear()) + ' - ' + DateUtil.formatDateFromString((currentSaturday.getMonth()+1)+'/'+currentSaturday.DateUtil.formatDateFromString()+'/'+currentSaturday.getFullYear());
}

private function showCurrentMonth():void {
	currentMonth = new Date(today.getTime() + currentMonthDiff * ((365.2425/12)*millisecondsPerDay));
	nutJournalDate.text = Constants.MONTHS[currentMonth.getMonth()] + ', ' + currentMonth.getFullYear();
	lblNutMonthlyAvg.text = 'Average daily calories for\nthe month of ' + Constants.MONTHS[currentMonth.getMonth()];
	/*currentYearDiff = Math.floor((today.getMonth() + currentMonthDiff) / 12);
	adjustedCurrentMonthDiff = (today.getMonth() + currentMonthDiff < 0) ? 
	currentMonth = (today.getMonth() + currentMonthDiff) % 12;
	nutJournalDate.text = arrMonths[currentMonth] + ', ' + today.getFullYear();*/
}