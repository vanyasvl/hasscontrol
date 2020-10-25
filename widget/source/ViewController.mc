using Toybox.WatchUi as Ui;
using Toybox.Timer;
using Toybox.Time;

class ViewController {
  hidden var _currentView;
  hidden var _loaderView;
  hidden var _errorView;
  hidden var _errorDelegate;
  hidden var _loginView;
  hidden var _loginDelegate;
  hidden var _loaderActive;
  hidden var _loaderTimer;
  hidden var _sceneView;
  hidden var _sceneDelegate;
  hidden var _sceneController;

  hidden var _entityView;
  hidden var _entityDelegate;
  hidden var _entityController;

  function initialize() {
    _loaderView = new ProgressView();
    _errorView = new ErrorView();
    _errorDelegate = new ErrorDelegate();
    _loginView = new LoginView();
    _loginDelegate = new LoginDelegate();
    _loaderActive = null;
    _loaderTimer = new Timer.Timer();

    _sceneController = new SceneController();
    _sceneView = new SceneView(_sceneController);
    _sceneDelegate = new SceneDelegate(_sceneController);

    _entityController = new EntityController();
    _entityView = new EntityView(_entityController);
    _entityDelegate = new EntityDelegate(_entityController);
  }


  // TODO:
  // Delay för att stänga loader
  // vad händer om användaren stänger loader innan appen stänger loader?


  function refresh() {
    _sceneController.refreshScenes();
  }


  // Since the progress bar is not a normal view,
  // We need to work around that it doesnt have onHide and onShow
  function isShowingLoader() {
    return _loaderActive != null && !_errorView.isActive() && !_loginView.isActive();
  }

  function pushSceneView() {
    Ui.pushView(
        _sceneView,
        _sceneDelegate,
        Ui.SLIDE_IMMEDIATE
    );
  }

  function switchSceneView() {
    Ui.switchToView(
        _sceneView,
        _sceneDelegate,
        Ui.SLIDE_IMMEDIATE
    );
  }

  function pushEntityView() {
    Ui.pushView(
        _entityView,
        _entityDelegate,
        Ui.SLIDE_IMMEDIATE
    );
  }

  function switchEntityView() {
    Ui.switchToView(
        _entityView,
        _entityDelegate,
        Ui.SLIDE_IMMEDIATE
    );
  }

  function showLoginView(show) {
    System.println("Show login? " + show);
    if (!_loginView.isActive() && show == true) {
      Ui.pushView(_loginView, _loginDelegate, Ui.SLIDE_IMMEDIATE);

      Ui.requestUpdate();
    }

    if (_loginView.isActive() && show == false) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);

      Ui.requestUpdate();
    }

  }
 
  function showLoader(text) {
    if (isShowingLoader()) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    _loaderView.setDisplayString(text);

    Ui.pushView(_loaderView, null, Ui.SLIDE_BLINK);

    _loaderActive = Time.now();

    Ui.requestUpdate();
  }


  function removeLoader() {
    System.println("About to remove loader");
    if (isShowingLoader()) {
      // if loader is about to close too soon, we need to delay it
      if (Time.now().add(new Time.Duration(-1)).lessThan(_loaderActive)) {
        _loaderTimer.start(method(:removeLoader), 500, false);
        return;
      }

      Ui.popView(Ui.SLIDE_BLINK);
    } else {
      System.println("Loader is not visible");
    }

    _loaderActive = null;
  }

  function removeLoaderImmediate() {
    if (isShowingLoader()) {
      Ui.popView(Ui.SLIDE_BLINK);
    }

    _loaderActive = null;
  }

  function showError(error) {
    removeLoaderImmediate();

    var message = "Unknown Error";

    if (error instanceof Error) {
      message = error.toShortString();

      if (error.code == Error.ERROR_UNKNOWN && error.responseCode != null) {
        message += "\ncode ";
        message += error.responseCode;

        if (error instanceof OAuthError) {
          message += "\nauth ";
        }
      }
    } else if (error instanceof String) {
      message = error;
    }

    if (_errorView.isActive()) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    _errorView.setMessage(message);

    Ui.pushView(_errorView, _errorDelegate, Ui.SLIDE_IMMEDIATE);

    Ui.requestUpdate();
  }

  function removeError() {
    if (_errorView.isActive()) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
  }
}