document.addEventListener('DOMContentLoaded', function() {
    
    // --- Theme Switcher ---
    const themeSwitcher = document.getElementById('theme-switcher');
    const doc = document.documentElement;
    const currentTheme = localStorage.getItem('theme') || 'dark';
    doc.setAttribute('data-theme', currentTheme);
    themeSwitcher.addEventListener('click', () => {
        let newTheme = doc.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        doc.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
    });



    



    // --- Mobile Navigation Toggle ---
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    const closeMenu = () => {
        hamburger.classList.remove('active');
        navMenu.classList.remove('active');
        document.body.style.overflow = '';
    };
    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
        document.body.style.overflow = navMenu.classList.contains('active') ? 'hidden' : '';
    });
    document.querySelectorAll('.nav-link').forEach(n => n.addEventListener('click', closeMenu));

    // --- Navbar Style on Scroll ---
    const navbar = document.querySelector('.navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // --- Active Navigation Link Highlighting on Scroll ---
    const sections = document.querySelectorAll('section');
    const navLinks = document.querySelectorAll('.nav-link');
    const setActiveNavLink = () => {
        let current = '';
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            if (pageYOffset >= sectionTop - 150) {
                current = section.getAttribute('id');
            }
        });
        navLinks.forEach(link => {
            link.classList.remove('active');
            const href = link.getAttribute('href');
            if (href && href.includes(current)) {
                link.classList.add('active');
            }
        });
    };
    window.addEventListener('scroll', setActiveNavLink);

    // --- General Scroll Animation (Fade-in) ---
    const animatedElements = document.querySelectorAll('.animate-on-scroll');
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const delay = entry.target.dataset.animationDelay || 0;
                setTimeout(() => {
                    entry.target.classList.add('is-visible');
                }, delay);
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1 });
    animatedElements.forEach(el => observer.observe(el));
    
    
     const allCards = document.querySelectorAll('.link-card, .team-card, .supervisor-card');
    allCards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            card.style.setProperty('--mouse-x', `${x}px`);
            card.style.setProperty('--mouse-y', `${y}px`);
        });
    });

    // === NEW: Typing Animation for Hero Title ===
    const heroTitle = document.querySelector('.hero-title');
    if (heroTitle) {
        const textToType = heroTitle.textContent;
        heroTitle.textContent = ''; // Clear the initial text
        heroTitle.classList.add('typing-cursor'); // Add cursor at the beginning

        let i = 0;
        function typeWriter() {
            if (i < textToType.length) {
                heroTitle.textContent += textToType.charAt(i);
                i++;
                setTimeout(typeWriter, 150); // Adjust typing speed (in ms)
            } else {
                // Optional: remove cursor after typing is done
                setTimeout(() => {
                    heroTitle.classList.remove('typing-cursor');
                }, 2000); // Wait 2 seconds before removing cursor
            }
        }
        // Start the animation after a short delay
        setTimeout(typeWriter, 500);
    }

    

    // --- Image Lightbox Functionality ---
    const lightbox = document.getElementById('lightbox');
    if (lightbox) {
        const lightboxImg = document.getElementById('lightbox-img');
        const enlargeableImages = document.querySelectorAll('img[data-enlargeable]');
        const closeBtn = document.querySelector('.lightbox-close-btn');

        enlargeableImages.forEach(img => {
            img.addEventListener('click', () => {
                lightboxImg.src = img.src;
                lightbox.classList.add('active');
                document.body.style.overflow = 'hidden';
            });
        });

        const closeLightbox = () => {
            lightbox.classList.remove('active');
            document.body.style.overflow = '';
        };

        if(closeBtn) {
            closeBtn.addEventListener('click', closeLightbox);
        }
        lightbox.addEventListener('click', (e) => {
            if (e.target === lightbox) {
                closeLightbox();
            }
        });
    }

    // === NEW LOGIC FOR INTRO VIDEO POPUP ===
    function createVideoPopup(videoId) {
        const overlay = document.createElement('div');
        overlay.className = 'lightbox active'; // Reuse lightbox style for the background
        
        const iframe = document.createElement('iframe');
        iframe.className = 'lightbox-content'; // Reuse lightbox style for the video player
        iframe.src = `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0&modestbranding=1`;
        iframe.setAttribute('frameborder', '0');
        iframe.setAttribute('allow', 'autoplay; encrypted-media');
        iframe.setAttribute('allowfullscreen', '');

        const closeBtn = document.createElement('span');
        closeBtn.className = 'lightbox-close-btn';
        closeBtn.innerHTML = '×';

        overlay.appendChild(iframe);
        overlay.appendChild(closeBtn);
        document.body.appendChild(overlay);
        document.body.style.overflow = 'hidden';

        const closePopup = () => {
            document.body.removeChild(overlay);
            document.body.style.overflow = '';
        };

        closeBtn.addEventListener('click', closePopup);
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) {
                closePopup();
            }
        });
    }

    // Attach listener to the intro video button
    const introButton = document.getElementById('play-intro-video-btn');
    if (introButton) {
        introButton.addEventListener('click', function(e) {
            e.preventDefault();
            createVideoPopup('mZcuyiRoe2s'); // YouTube ID for the intro video
        });
    }
    
    // === ORIGINAL LOGIC FOR FINAL PRODUCT VIDEO ===
    const finalProductVideoContainer = document.querySelector('#final-product .video-container');
    if (finalProductVideoContainer) {
        const placeholder = finalProductVideoContainer.querySelector('.video-placeholder');
        const videoOverlay = finalProductVideoContainer.querySelector('.video-overlay');
        const iframe = videoOverlay.querySelector('iframe');
        const videoId = finalProductVideoContainer.dataset.videoId;

        if (placeholder && videoOverlay && iframe && videoId) {
            placeholder.addEventListener('click', () => {
                iframe.src = `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0&modestbranding=1`;
                videoOverlay.classList.add('active');
            });
        }
    }
});