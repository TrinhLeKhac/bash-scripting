# Exercise 2: Web Development Build Pipeline

## Objective
Create a comprehensive Makefile for a web development project with CSS/JS minification, asset optimization, and automated deployment.

## Project Structure
```
web_project/
├── src/
│   ├── css/
│   │   ├── main.css
│   │   ├── components.css
│   │   └── responsive.css
│   ├── js/
│   │   ├── app.js
│   │   ├── utils.js
│   │   └── components.js
│   ├── images/
│   │   ├── logo.png
│   │   └── background.jpg
│   └── html/
│       ├── index.html
│       └── about.html
├── dist/
├── node_modules/
├── package.json
└── Makefile
```

## Requirements

### Basic Features
1. **CSS Processing**: Concatenate and minify CSS files
2. **JS Processing**: Concatenate, minify, and uglify JavaScript
3. **HTML Processing**: Minify HTML and inject asset references
4. **Image Optimization**: Compress images without quality loss
5. **Asset Versioning**: Add hash to filenames for cache busting

### Advanced Features
1. **SASS/SCSS Support**: Compile SASS to CSS
2. **TypeScript Support**: Compile TypeScript to JavaScript
3. **Live Reload**: Watch files and rebuild automatically
4. **Linting**: ESLint for JavaScript, stylelint for CSS
5. **Testing**: Run unit tests for JavaScript code
6. **Bundle Analysis**: Analyze bundle sizes and dependencies

### Deployment Features
1. **FTP Deploy**: Upload to FTP server
2. **S3 Deploy**: Deploy to AWS S3 bucket
3. **CDN Integration**: Upload assets to CDN
4. **Environment Configs**: Different builds for dev/staging/prod

## Expected Targets

```bash
make                # Build production version
make dev            # Build development version
make watch          # Watch files and rebuild
make serve          # Start development server
make lint           # Run all linters
make test           # Run JavaScript tests
make optimize       # Optimize all assets
make deploy-staging # Deploy to staging
make deploy-prod    # Deploy to production
make clean          # Clean build artifacts
```

## Sample Files to Create

### src/css/main.css
```css
/* Main stylesheet */
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
    background-color: #f5f5f5;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
}
```

### src/js/app.js
```javascript
// Main application JavaScript
(function() {
    'use strict';
    
    function initApp() {
        console.log('App initialized');
        setupEventListeners();
    }
    
    function setupEventListeners() {
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM loaded');
        });
    }
    
    initApp();
})();
```

### package.json
```json
{
  "name": "web-project",
  "version": "1.0.0",
  "devDependencies": {
    "uglify-js": "^3.17.4",
    "clean-css-cli": "^5.6.2",
    "html-minifier": "^4.0.0",
    "imagemin-cli": "^7.0.0",
    "eslint": "^8.0.0",
    "stylelint": "^15.0.0"
  }
}
```

## Build Pipeline Steps

### Development Build
1. Compile SASS/SCSS to CSS
2. Concatenate CSS files
3. Concatenate JavaScript files
4. Copy HTML files with development asset paths
5. Copy images without optimization
6. Generate source maps

### Production Build
1. Compile and minify CSS
2. Minify and uglify JavaScript
3. Optimize and compress images
4. Minify HTML
5. Add version hashes to filenames
6. Generate asset manifest
7. Create gzipped versions

## Testing Your Makefile

1. Install Node.js dependencies: `npm install`
2. Create sample source files
3. Test development build: `make dev`
4. Test production build: `make`
5. Test watch mode: `make watch`
6. Test deployment: `make deploy-staging`

## Advanced Challenges

1. **Webpack Integration**: Use webpack for advanced bundling
2. **Progressive Web App**: Generate service worker and manifest
3. **Critical CSS**: Extract above-the-fold CSS
4. **Tree Shaking**: Remove unused JavaScript code
5. **Code Splitting**: Split JavaScript into chunks
6. **Performance Budget**: Fail build if assets exceed size limits