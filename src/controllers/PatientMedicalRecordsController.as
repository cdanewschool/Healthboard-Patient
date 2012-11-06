package controllers
{
	public class PatientMedicalRecordsController extends MedicalRecordsController
	{
		public function PatientMedicalRecordsController()
		{
			super();
		}
		
		override public function init():void
		{
			super.init();
			
			model.dataService.send();
		}
	}
}