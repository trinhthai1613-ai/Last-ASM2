// Main JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize tooltips
    initTooltips();
    
    // Initialize form validation
    initFormValidation();
    
    // Initialize smooth scrolling
    initSmoothScroll();
    
    // Initialize animations
    initAnimations();
});

// Tooltips
function initTooltips() {
    const tooltips = document.querySelectorAll('[data-tooltip]');
    tooltips.forEach(element => {
        element.addEventListener('mouseenter', showTooltip);
        element.addEventListener('mouseleave', hideTooltip);
    });
}

function showTooltip(e) {
    const text = e.target.getAttribute('data-tooltip');
    const tooltip = document.createElement('div');
    tooltip.className = 'tooltip';
    tooltip.textContent = text;
    tooltip.style.position = 'absolute';
    tooltip.style.background = 'rgba(10, 14, 39, 0.9)';
    tooltip.style.color = '#fff';
    tooltip.style.padding = '8px 12px';
    tooltip.style.borderRadius = '8px';
    tooltip.style.fontSize = '12px';
    tooltip.style.zIndex = '9999';
    
    document.body.appendChild(tooltip);
    
    const rect = e.target.getBoundingClientRect();
    tooltip.style.top = (rect.top - tooltip.offsetHeight - 10) + 'px';
    tooltip.style.left = (rect.left + rect.width / 2 - tooltip.offsetWidth / 2) + 'px';
    
    e.target.tooltipElement = tooltip;
}

function hideTooltip(e) {
    if (e.target.tooltipElement) {
        e.target.tooltipElement.remove();
        delete e.target.tooltipElement;
    }
}

// Form Validation
function initFormValidation() {
    const forms = document.querySelectorAll('form[data-validate]');
    forms.forEach(form => {
        form.addEventListener('submit', validateForm);
    });
}

function validateForm(e) {
    const form = e.target;
    const inputs = form.querySelectorAll('input[required], textarea[required], select[required]');
    let isValid = true;
    
    inputs.forEach(input => {
        if (!input.value.trim()) {
            isValid = false;
            showError(input, 'Trường này không được để trống');
        } else {
            clearError(input);
        }
    });
    
    if (!isValid) {
        e.preventDefault();
    }
    
    return isValid;
}

function showError(input, message) {
    clearError(input);
    
    const error = document.createElement('div');
    error.className = 'error-message';
    error.textContent = message;
    error.style.color = '#ef4444';
    error.style.fontSize = '13px';
    error.style.marginTop = '5px';
    
    input.parentElement.appendChild(error);
    input.style.borderColor = '#ef4444';
}

function clearError(input) {
    const error = input.parentElement.querySelector('.error-message');
    if (error) {
        error.remove();
    }
    input.style.borderColor = '';
}

// Smooth Scrolling
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// Animations
function initAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('fade-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    document.querySelectorAll('.animate-on-scroll').forEach(el => {
        observer.observe(el);
    });
}

// Show Loading
function showLoading() {
    const loading = document.createElement('div');
    loading.id = 'loading-overlay';
    loading.innerHTML = `
        <div style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(10, 14, 39, 0.95);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        ">
            <div class="spinner"></div>
        </div>
    `;
    document.body.appendChild(loading);
}

function hideLoading() {
    const loading = document.getElementById('loading-overlay');
    if (loading) {
        loading.remove();
    }
}

// Show Toast Notification
function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    toast.style.position = 'fixed';
    toast.style.top = '20px';
    toast.style.right = '20px';
    toast.style.padding = '15px 25px';
    toast.style.borderRadius = '12px';
    toast.style.zIndex = '10000';
    toast.style.animation = 'slideInRight 0.5s ease';
    
    if (type === 'success') {
        toast.style.background = 'rgba(34, 197, 94, 0.9)';
    } else if (type === 'error') {
        toast.style.background = 'rgba(239, 68, 68, 0.9)';
    } else {
        toast.style.background = 'rgba(99, 102, 241, 0.9)';
    }
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.5s ease';
        setTimeout(() => toast.remove(), 500);
    }, 3000);
}

// Confirm Dialog
function confirmDialog(message) {
    return confirm(message);
}

// Date Picker Helper
function initDatePickers() {
    const dateInputs = document.querySelectorAll('input[type="date"]');
    dateInputs.forEach(input => {
        input.min = new Date().toISOString().split('T')[0];
    });
}