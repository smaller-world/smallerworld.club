// Import and register all your controllers from the importmap via controllers/**/*_controller
import TextareaAutogrowController from "stimulus-textarea-autogrow";

// import { registerControllers } from "stimulus-vite-helpers";
import { application } from "./application";
import FilepondController from "./filepond_controller";
import HelloController from "./hello_controller";
import PreventSubmitWhileBusyController from "./prevent_submit_while_busy_controller";

application.register("textarea-autogrow", TextareaAutogrowController);
application.register("hello", HelloController);
application.register("filepond", FilepondController);
application.register(
  "prevent-submit-while-busy",
  PreventSubmitWhileBusyController,
);
// const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
// registerControllers(application, controllers);
