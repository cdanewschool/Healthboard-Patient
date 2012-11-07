package controllers
{
	import components.popups.RecordIntakePopup;
	
	import mx.managers.PopUpManager;

	public class PatientMedicationsController extends MedicationsController
	{
		public function PatientMedicationsController()
		{
			super();
		}
		
		override public function onRecordIntakeClick():void
		{
			var popup:RecordIntakePopup = PopUpManager.createPopUp( AppProperties.getInstance().controller.application, RecordIntakePopup ) as RecordIntakePopup;
			PopUpManager.centerPopUp( popup );
		}
	}
}