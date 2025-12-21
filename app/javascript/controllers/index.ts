// @ts-expect-error - Untyped package
import { ButtonBridgeController } from "@joemasilotti/bridge-components";
import TextareaAutogrowController from "stimulus-textarea-autogrow";

import { application } from "./application";
import ElementRemovalController from "./element_removal_controller";
import FilepondController from "./filepond_controller";
import HelloController from "./hello_controller";
import ModalController from "./modal_controller";
import PreventSubmitWhileBusyController from "./prevent_submit_while_busy_controller";

// == Native bridge components ==
/* eslint-disable @typescript-eslint/no-unsafe-argument */
application.register("button-bridge", ButtonBridgeController);
/* eslint-enable @typescript-eslint/no-unsafe-argument */

application.register("textarea-autogrow", TextareaAutogrowController);

application.register("element-removal", ElementRemovalController);
application.register("hello", HelloController);
application.register("filepond", FilepondController);
application.register(
  "prevent-submit-while-busy",
  PreventSubmitWhileBusyController,
);
application.register("modal", ModalController);
