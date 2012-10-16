/**
 * NOTE: This file has been deprecated, and has been replaced by EducationalResourcesController, EducationalResourcesModel and EducationalResourcesModule.
 */
import components.educationalResources.bookmarkAdd;
import components.educationalResources.bookmarkRemove;

import mx.collections.ArrayCollection;
import mx.managers.PopUpManager;

import spark.components.TitleWindow;

[Embed(source="images/smallArrowCollapsedBlue.png")]
[Bindable] public var blueArrow:Class;

[Embed(source="images/smallArrowCollapsed.png")]
[Bindable] public var whiteArrow:Class;

[Bindable] public var erBookmarks:ArrayCollection = new ArrayCollection([
	{label: "Food & Diet", data: 1},
	{label: "Facts About Fat", data: 2}
]);

private var arrTitles:Array = new Array("Educational Resources Home","Food & Diet","Facts About Fat","Related Links","Search Results","Diabetes Basics — Symptoms","placeholder","Heartburn/GRED Home","Physical Conditions","Digestive Disorders","Heartburn/GERD","Mental Conditions");
[Bindable] public var arrBookmarkIndices:Array = new Array(1,2); 

private function erDisplayBookmark(item:Object):void {
	viewsEducationalResources.selectedIndex = viewsEducationalResourcesMenu.selectedIndex = viewsEducationalResourcesBreadcrumb.selectedIndex = item.data;
}

private function erAddBookmark():void {
	if(viewsEducationalResources.selectedIndex != 4 && viewsEducationalResources.selectedIndex != 6) {
		erBookmarks.addItemAt({label: arrTitles[viewsEducationalResources.selectedIndex], data: viewsEducationalResources.selectedIndex}, 0);
		erBookmark0.visible = erBookmark0.includeInLayout = false;
		erBookmark1.visible = erBookmark1.includeInLayout = true;
		arrBookmarkIndices.splice(0,0,viewsEducationalResources.selectedIndex);
		
		var myBookmarkAdd:bookmarkAdd = bookmarkAdd(PopUpManager.createPopUp(this, bookmarkAdd) as spark.components.TitleWindow);
		myBookmarkAdd.bookmarkLabel = arrTitles[viewsEducationalResources.selectedIndex];
		PopUpManager.centerPopUp(myBookmarkAdd);
	}
}

private function erRemoveBookmark():void {
	var myBookmarkRemove:bookmarkRemove = bookmarkRemove(PopUpManager.createPopUp(this, bookmarkRemove) as spark.components.TitleWindow);
	PopUpManager.centerPopUp(myBookmarkRemove);
}

[Bindable] private var resourceNames:Array = new Array("Diabetes diet","Diabetes symptoms","Diabetes pictures","Diabetes treatment","Diabetes prevention","Heartburn basics","Heartburn remedies","Heartburn during pregnancy","Heartburn relief","Heartburn prevention");