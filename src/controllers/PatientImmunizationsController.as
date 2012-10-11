package controllers
{
	import models.PatientImmunizationsModel;
	
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

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