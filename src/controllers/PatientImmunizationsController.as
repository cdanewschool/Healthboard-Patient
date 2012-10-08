package controllers
{
	import models.PatientImmunizationsModel;

	public class PatientImmunizationsController extends ImmunizationsController
	{
		public function PatientImmunizationsController()
		{
			super();
			
			model = new PatientImmunizationsModel();
		}
	}
}