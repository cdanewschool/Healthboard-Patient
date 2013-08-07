package edu.newschool.piim.healthboard.controller
{
	import edu.newschool.piim.healthboard.Constants;
	
	
	import edu.newschool.piim.healthboard.constant.PatientConstants;
	import edu.newschool.piim.healthboard.model.PatientApplicationModel;
	import edu.newschool.piim.healthboard.model.UserPreferences;
	import edu.newschool.piim.healthboard.view.components.home.NextStepsOverlay;
	import edu.newschool.piim.healthboard.view.components.home.preferencesWindow;
	import edu.newschool.piim.healthboard.view.components.widgets.EducationalResourcesWidget;
	
	import edu.newschool.piim.healthboard.enum.ViewModeType;
	
	import edu.newschool.piim.healthboard.events.ApplicationDataEvent;
	import edu.newschool.piim.healthboard.events.ApplicationEvent;
	import edu.newschool.piim.healthboard.events.AuthenticationEvent;
	
	import net.flexwiz.blog.tabbar.plus.TabBarPlus;
	
	import edu.newschool.piim.healthboard.model.PatientsModel;
	import edu.newschool.piim.healthboard.model.Preferences;
	import edu.newschool.piim.healthboard.model.UserModel;
	import edu.newschool.piim.healthboard.model.module.AppointmentsModel;
	import edu.newschool.piim.healthboard.model.module.MedicalRecordsModel;
	import edu.newschool.piim.healthboard.model.module.MessagesModel;
	import edu.newschool.piim.healthboard.model.module.appointments.PatientAppointment;
	import edu.newschool.piim.healthboard.model.module.medicalrecords.MedicalRecord;
	
	import edu.newschool.piim.healthboard.view.modules.NutritionModule;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	public class MainController extends Controller
	{
		[Bindable] public var nextStepsOverlay:NextStepsOverlay;
		
		public function MainController()
		{
			super();
			
			model = new PatientApplicationModel();
			
			appointmentsController = new PatientAppointmentsController();
			exerciseController = new PatientExerciseController();
			immunizationsController = new PatientImmunizationsController();
			medicalRecordsController = new PatientMedicalRecordsController();
			medicationsController = new PatientMedicationsController();
			nutritionController = new NutritionController();
			vitalSignsController = new VitalSignsController();
			
			appointmentsController.model.addEventListener( ApplicationDataEvent.LOADED, onAppointmentsLoaded );
			patientsController.model.addEventListener( ApplicationDataEvent.LOADED, onPatientsLoaded );
			providersController.model.addEventListener( ApplicationDataEvent.LOADED, onProvidersLoaded );
			
			loadStyles();
		}
		
		override protected function onInitialized():void
		{
			if( !initialized ) return;
			
			if( Constants.DEBUG ) 
			{
				for each(var patient:UserModel in PatientsModel(patientsController.model).patients)
				{
					if( patient.id == PatientConstants.DEBUG_USER_ID ) 
					{
						model.user = patient;
						
						application.dispatchEvent( new AuthenticationEvent( AuthenticationEvent.SUCCESS, true ) );
						
						break;
					}
				}
			}
		}
		
		override public function validateUser( username:String, password:String ):UserModel
		{
			for each(var patient:UserModel in PatientsModel(patientsController.model).patients)
			{
				if( patient.username == username && patient.password == password ) 
				{
					return patient;
				}
			}
			
			return null;
		}
		
		override public function getDefaultUser():UserModel
		{
			for each(var patient:UserModel in PatientsModel(patientsController.model).patients)
			{
				if( patient.id == PatientConstants.DEBUG_USER_ID ) 
				{
					return patient;
				}
			}
			
			return null;
		}
		
		override public function showPreferences():UIComponent
		{
			var popup:preferencesWindow = preferencesWindow( PopUpManager.createPopUp(application, preferencesWindow) as TitleWindow );
			popup.preferences = model.preferences.clone() as UserPreferences;
			PopUpManager.centerPopUp(popup);
			
			return popup;
		}
		
		override protected function loadPreferences():void
		{
			if( persistentData 
				&& persistentData.data.hasOwnProperty('preferences') )
			{
				model.preferences = UserPreferences.fromObj( persistentData.data['preferences'] );
			}
			else
			{
				model.preferences = new UserPreferences();
				savePreferences( model.preferences );
			}
			
			processPreferences();
		}
		
		override public function savePreferences( preferences:Preferences ):void
		{
			super.savePreferences(preferences);
			
			persistentData.data['preferences'] = preferences;
			persistentData.flush();
		}
		
		override protected function processPreferences( preferences:Preferences = null ):void
		{
			if( preferences == null ) preferences  = model.preferences;
			
			super.processPreferences( preferences );
			
			if( preferences 
				&& preferences.viewMode != model.preferences.viewMode )
			{
				var state:String = preferences.viewMode == ViewModeType.WIDGET ? Constants.STATE_WIDGET_VIEW : Constants.STATE_LOGGED_IN;
				
				application.dispatchEvent( new ApplicationEvent( ApplicationEvent.SET_STATE, true, false, state) );
			}
		}
		
		public function showNextStepsOverlay():void
		{
			if( nextStepsOverlay ) 
			{
				onNextStepsClose()
				
				return;
			}
			
			nextStepsOverlay= PopUpManager.createPopUp( application, NextStepsOverlay ) as NextStepsOverlay;
			nextStepsOverlay.addEventListener( CloseEvent.CLOSE, onNextStepsClose );
			nextStepsOverlay.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onNextStepsOutsideClick);
			
			nextStepsOverlay.x = application.stage.width/2 - nextStepsOverlay.width/2;
			nextStepsOverlay.y = Main(application).header.height - 1;
		}
		
		private function onNextStepsClose( event:CloseEvent = null ):void
		{
			PopUpManager.removePopUp( nextStepsOverlay );
			
			nextStepsOverlay.removeEventListener( CloseEvent.CLOSE, onNextStepsClose );
			nextStepsOverlay = null;
		}
		
		private function onNextStepsOutsideClick( event:FlexMouseEvent = null ):void
		{
			if(!Main(application).nextStepsTrigger.hitTestPoint(event.stageX,event.stageY)) onNextStepsClose();
		}
		
		override protected function onAuthenticated(event:AuthenticationEvent):void
		{
			if( !initialized )
			{
				medicationsController.init();
			}
			
			super.onAuthenticated( event );
		}
		
		override protected function onNavigate( event:ApplicationEvent ):void
		{
			super.onNavigate(event);

			closeNextStepsOverlay();
		}
		
		override protected function onSetState( event:ApplicationEvent ):void
		{
			super.onSetState( event );
			
			var dashboard:Main = application as Main;
			
			if( application.currentState == Constants.MODULE_MESSAGES
				&& event.message )
			{
				MessagesModel(messagesController.model).pendingRecipientType = event.message.recipientType;
			}
			else if( application.currentState == Constants.MODULE_EDUCATIONAL_RESOURCES )
			{
				if( event.target is NutritionModule )
				{
					dashboard.educationalResourcesModule.viewsEducationalResources.selectedIndex = 1; 
					dashboard.educationalResourcesModule.viewsEducationalResourcesMenu.selectedIndex = 1; 
					dashboard.educationalResourcesModule.viewsEducationalResourcesBreadcrumb.selectedIndex = 1;
				}
				else if( event.target is EducationalResourcesWidget )
				{
					if( dashboard.widgetEducationalResources.viewIndex > -1 )
						dashboard.educationalResourcesModule.viewsEducationalResources.selectedIndex = dashboard.widgetEducationalResources.viewIndex;
					
					if( dashboard.widgetEducationalResources.menuIndex > -1 )
						dashboard.educationalResourcesModule.viewsEducationalResourcesMenu.selectedIndex = dashboard.widgetEducationalResources.menuIndex;
					
					if( dashboard.widgetEducationalResources.breadcrumbIndex > -1 )
						dashboard.educationalResourcesModule.viewsEducationalResourcesBreadcrumb.selectedIndex = dashboard.widgetEducationalResources.breadcrumbIndex;
				}
				
			}
			
			closeNextStepsOverlay();
		}
		
		override protected function onTabClose(event:ListEvent):void
		{
			super.onTabClose(event);
			
			var dashboard:Main = application as Main;
			
			if( TabBarPlus( event.target.owner).dataProvider is IList )
			{
				var dataProvider:IList = TabBarPlus( event.target.owner).dataProvider as IList;
				var index:int = event.rowIndex;
				
				if( application.currentState == "modMedications" ) 
				{
					medicationsController.model.openTabs.splice(index-1,1);
				}
				else if( application.currentState == "modImmunizations" ) 
				{
					immunizationsController.model.openTabs.splice(index-1,1);
				}
			}
			else 
			{
				trace("Bad data provider");
			}
		}
		
		private function closeNextStepsOverlay():void
		{
			if( nextStepsOverlay
				&& nextStepsOverlay.parent )
			{
				nextStepsOverlay.dispatchEvent( new CloseEvent( CloseEvent.CLOSE, true ) );
				
				nextStepsOverlay = null;
			}
		}
		
		override protected function get id():String
		{
			return 'visualDashboardPatient';
		}
	}
}