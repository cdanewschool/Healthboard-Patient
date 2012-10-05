package controllers
{
	import controllers.Controller;
	
	public class MainController extends Controller
	{
		public function MainController()
		{
			super();
			
			medicalRecordsController = new PatientMedicalRecordsController();
			medicationsController = new PatientMedicationsController();
		}
	}
}