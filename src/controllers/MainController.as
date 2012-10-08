package controllers
{
	import controllers.Controller;
	
	public class MainController extends Controller
	{
		public function MainController()
		{
			super();
			
			exerciseController = new PatientExerciseController();
			immunizationsController = new PatientImmunizationsController();
			medicalRecordsController = new PatientMedicalRecordsController();
			medicationsController = new PatientMedicationsController();
		}
	}
}