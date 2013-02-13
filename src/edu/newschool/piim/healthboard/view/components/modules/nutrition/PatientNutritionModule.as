package edu.newschool.piim.healthboard.view.components.modules.nutrition
{
	import edu.newschool.piim.healthboard.view.modules.NutritionModule;
	
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	public class PatientNutritionModule extends NutritionModule
	{
		public function PatientNutritionModule()
		{
			super();
		}
		
		override protected function init():void 
		{
			super.init();
			
			showTip();
		}
		
		private function showTip():void 
		{
			var nutritionTips:NutritionTips = NutritionTips(PopUpManager.createPopUp(AppProperties.getInstance().controller.application, NutritionTips) as TitleWindow);
			PopUpManager.centerPopUp(nutritionTips);
		}
	}
}