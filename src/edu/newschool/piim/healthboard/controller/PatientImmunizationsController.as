package edu.newschool.piim.healthboard.controller
{
	import edu.newschool.piim.healthboard.model.PatientImmunizationsModel;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;
	import controllers.ImmunizationsController;

	public class PatientImmunizationsController extends ImmunizationsController
	{
		public function PatientImmunizationsController()
		{
			super();
			
			model = new PatientImmunizationsModel();
			model.dataService.url = "data/immunizations.xml";
			model.dataService.addEventListener( ResultEvent.RESULT, dataResultHandler );
		}
	}
}