import TextareaAutogrowController from "stimulus-textarea-autogrow";

// import { registerControllers } from "stimulus-vite-helpers";
import { application } from "./application";
import FilepondController from "./filepond_controller";
import HelloController from "./hello_controller";
import ModalController from "./modal_controller";
import PreventSubmitWhileBusyController from "./prevent_submit_while_busy_controller";

application.register("textarea-autogrow", TextareaAutogrowController);
application.register("hello", HelloController);
application.register("filepond", FilepondController);
application.register(
  "prevent-submit-while-busy",
  PreventSubmitWhileBusyController,
);
application.register("modal", ModalController);

// const controllers = import.meta.glob("./**/*_controller.js", { eager: true });
// registerControllers(application, controllers);
