---
name: Port Landing Page to Rails View
overview:
  Port the existing React `LandingPage` component to a Rails view
  (`app/views/pages/landing.html.erb`) using Tailwind CSS and a Stimulus
  controller for video playback.
todos:
  - id: "1"
    content: Create video stimulus controller
    status: pending
  - id: "2"
    content: Create how it works step partial in app/views/pages/landing/
    status: pending
  - id: "3"
    content: Create landing page view
    status: pending
---

# Plan: Port Landing Page to Rails View

I will port `app/pages/LandingPage.tsx` to `app/views/pages/landing.html.erb`,
replacing the React implementation with standard Rails ERB, Tailwind CSS, and
Stimulus.

## 1. Stimulus Controller for Video

Create `app/javascript/controllers/video_controller.ts` to handle video playback
interactions.

- **Targets**: `video`, `overlay`
- **Actions**:
- `play`: Triggered by overlay button click. Plays the video.
- `updateState`: Triggered by video events (`playing`, `pause`, `ended`).
  Toggles the overlay visibility.

## 2. Views

Create the directory structure `app/views/pages/landing/` and the necessary
files.

- **`app/views/pages/landing/_how_it_works_step.html.erb`**: Partial for the
  "How It Works" steps.
- **`app/views/pages/landing.html.erb`**: Main view.
- **Header**: "Welcome back" alert using `current_user` check.
- **Hero**: Title and Subtitle.
- **Video Section**:
- Uses `video_controller`.
- Includes the video element with `.webm` and `.mp4` sources (hosted on Supabase
  as per React code).
- Includes the overlay with the "Play" button.
- **Callout**: "Why I made this" section.
- **How It Works**: Renders the partial 3 times (referencing
  `pages/landing/how_it_works_step`).
- **Footer**: "Start your smaller world" section.

## 3. Assets & Styles

- Use `vite_image_tag "assets/images/..."` for static assets.
- Use Tailwind CSS for styling, matching the React implementation.
- Use standard Rails route helpers (e.g., `user_world_path`).
- If custom CSS is absolutely necessary (e.g. for specific animations or complex
  layouts not easily done with Tailwind), I will follow the project's naming
  convention (BEM-like) in a `<style>` block or suggest a new CSS file.

## Verification

- Ensure all assets are referenced correctly.
- Ensure video plays and overlay behaves correctly.
- Ensure responsiveness matches the original design (Stack/Group behaviors).
