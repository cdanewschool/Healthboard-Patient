package edu.newschool.piim.healthboard.controller
{
	import edu.newschool.piim.healthboard.view.popups.RecordIntakePopup;
	
	import mx.managers.PopUpManager;

	public class PatientMedicationsController extends MedicationsController
	{
		public function PatientMedicationsController()
		{
			super();
		}
		
		override public function onRecordIntakeClick(medication:Object):void
		{
			var popup:RecordIntakePopup = PopUpManager.createPopUp( AppProperties.getInstance().controller.application, RecordIntakePopup ) as RecordIntakePopup;
			popup.medication = medication;
			PopUpManager.centerPopUp( popup );
		}
	}
}