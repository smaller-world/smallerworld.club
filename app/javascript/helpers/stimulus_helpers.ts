import { type Controller } from "@hotwired/stimulus";

const updateActions = (
  element: HTMLElement,
  update: (actions: DOMTokenList) => void,
): void => {
  const parser = document.createElement("div");
  if (element.dataset.action) {
    parser.className = element.dataset.action;
  }
  update(parser.classList);
  element.dataset.action = parser.className;
};

export const addCleanupAction = (
  controller: Controller<HTMLElement>,
  action: string,
): void => {
  updateActions(controller.element, (actions) => {
    actions.add(
      `turbo:before-cache@document->${controller.identifier}#${action}`,
    );
  });
};

export const addAction = (
  controller: Controller<HTMLElement>,
  event: string,
  action: string,
): void => {
  updateActions(controller.element, (actions) => {
    actions.add(`${event}->${controller.identifier}#${action}`);
  });
};

export const removeAction = (
  controller: Controller<HTMLElement>,
  event: string,
  action: string,
): void => {
  updateActions(controller.element, (actions) => {
    actions.remove(`${event}->${controller.identifier}#${action}`);
  });
};

export const waitForTransitionAnimations = async (
  ...elements: HTMLElement[]
): Promise<void> => {
  const transitions = elements
    .flatMap((el) => el.getAnimations())
    .filter((animation) => animation instanceof CSSTransition);
  await Promise.allSettled(transitions.map(({ finished }) => finished));
};
