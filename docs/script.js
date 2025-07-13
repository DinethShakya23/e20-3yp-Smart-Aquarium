document.addEventListener('DOMContentLoaded', function() {
    
    // --- Mobile Navigation Toggle ---
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    
    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        navMenu.classList.toggle('active');
        document.body.style.overflow = navMenu.classList.contains('active') ? 'hidden' : '';
    });
    
    document.querySelectorAll('.nav-link').forEach(n => n.addEventListener('click', () => {
        hamburger.classList.remove('active');
        navMenu.classList.remove('active');
        document.body.style.overflow = '';
    }));

    // --- Navbar Style on Scroll ---
    const navbar = document.querySelector('.navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.style.background = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.background = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = 'none';
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
            if (link.getAttribute('href') === '#' + current) {
                link.classList.add('active');
            }
        });
    };

    // --- General Scroll Animation (Fade-in) ---
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1
    });

    const elementsToAnimate = document.querySelectorAll('.intro-content, .intro-image, .image-placeholder, .team-card, .link-card, .supervisor-card, .video-container, .testing-column, .test-item');
    elementsToAnimate.forEach(el => {
        el.classList.add('fade-in');
        observer.observe(el);
    });

    // --- Hero Section Parallax Effect ---
    const heroContent = document.querySelector('.hero-content');
    const updateParallax = () => {
        const scrolled = window.pageYOffset;
        if (heroContent && window.innerWidth > 768) {
             heroContent.style.transform = `translateY(${scrolled * 0.3}px)`;
             heroContent.style.opacity = 1 - scrolled / 600;
        }
    };
    
    // --- Debounced Scroll Event Listener ---
    let ticking = false;
    window.addEventListener('scroll', () => {
        setActiveNavLink();
        updateParallax();
        if (!ticking) {
            window.requestAnimationFrame(() => {
                ticking = false;
            });
            ticking = true;
        }
    });

    // --- Video Player Functionality ---
    const videoContainers = document.querySelectorAll('.video-container');

    videoContainers.forEach(container => {
        const placeholder = container.querySelector('.video-placeholder');
        const videoOverlay = container.querySelector('.video-overlay');
        const iframe = videoOverlay.querySelector('iframe');
        const videoId = container.dataset.videoId;
        
        if (!videoId || !placeholder || !iframe) return;

        placeholder.addEventListener('click', () => {
            const videoUrl = `https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0&showinfo=0`;
            iframe.src = videoUrl;
            videoOverlay.classList.add('active');
        });
    });

    // --- Enhanced Hover Effects ---
    const cards = document.querySelectorAll('.link-card, .team-card, .supervisor-card, .test-item');
    cards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const rotateX = (y / rect.height - 0.5) * -10; // Max rotation 5deg
            const rotateY = (x / rect.width - 0.5) * 10;   // Max rotation 5deg
            
            card.style.transform = `perspective(1000px) translateY(-5px) rotateX(${rotateX}deg) rotateY(${rotateY}deg)`;
        });
        
        card.addEventListener('mouseleave', () => {
             card.style.transform = 'perspective(1000px) translateY(0) rotateX(0) rotateY(0)';
        });
    });

});