// Multicharacter NUI controller (selection, registration, staging modal)
const App = (() => {
    const appEl = document.getElementById('app');
    const skyBackdrop = document.getElementById('sky-backdrop');
    const selectScreen = document.getElementById('select-screen');
    const registerScreen = document.getElementById('register-screen');
    const stagingModal = document.getElementById('staging-modal');
    const confirmCityModal = document.getElementById('confirm-city-modal');
    const mouseStateEl = document.getElementById('staging-mouse-state');

    let characterData = [];
    let maxSlots = 4;
    let mouseOnAt = 0;

    const init = () => {
        RegisterModule.init();

        const btnDressUp = document.getElementById('btn-action-dressup');
        if (btnDressUp) {
            btnDressUp.addEventListener('click', () => {
                SoundManager.play('click');
                fetch(`https://${GetParentResourceName()}/actionDressUp`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                }).catch(() => {});
            });
        }

        const btnEnterCity = document.getElementById('btn-action-entercity');
        if (btnEnterCity) {
            btnEnterCity.addEventListener('click', () => {
                SoundManager.play('click');
                showScreen('confirm-city');
            });
        }

        const btnConfirmCancel = document.getElementById('confirm-city-cancel');
        if (btnConfirmCancel) {
            btnConfirmCancel.addEventListener('click', () => {
                SoundManager.play('click');
                showScreen('staging-modal');
            });
        }

        const btnConfirmOk = document.getElementById('confirm-city-ok');
        if (btnConfirmOk) {
            btnConfirmOk.addEventListener('click', () => {
                SoundManager.play('success');
                fetch(`https://${GetParentResourceName()}/actionEnterCity`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                }).catch(() => {});
            });
        }

        window.addEventListener('keydown', (event) => {
            if (confirmCityModal && !confirmCityModal.classList.contains('hidden')) {
                if (event.code === 'Escape') {
                    event.preventDefault();
                    showScreen('staging-modal');
                }
                return;
            }

            if (stagingModal && !stagingModal.classList.contains('hidden')) {
                if (event.code === 'KeyE' || event.code === 'Escape') {
                    if (Date.now() - mouseOnAt < 200) return;
                    event.preventDefault();
                    toggleMouse();
                }
            }
        });

        window.addEventListener('message', (event) => {
            const data = event.data;
            if (!data || !data.action) return;

            switch (data.action) {
                case 'openMulticharacter':
                    characterData = data.characters || [];
                    maxSlots = data.maxSlots || 4;
                    open(characterData, maxSlots);
                    break;

                case 'openRegisterDirect':
                    openRegisterOnly();
                    break;

                case 'openActionModal':
                    openActionModalView();
                    break;

                case 'setMouse':
                    if (data.enabled) mouseOnAt = Date.now();
                    if (appEl) appEl.classList.toggle('mouse-on', !!data.enabled);
                    if (mouseStateEl) mouseStateEl.textContent = data.enabled ? 'เมาส์เปิด' : 'เมาส์ปิด';
                    break;

                case 'closeUI':
                    close();
                    break;
            }
        });
    };

    const open = (characters, slots) => {
        appEl.classList.remove('hidden');
        if (!characters || characters.length === 0) {
            RegisterModule.resetForm();
            showScreen('register');
        } else {
            SelectModule.renderSlots(characters, slots);
            showScreen('select');
        }
    };

    const openRegisterOnly = () => {
        appEl.classList.remove('hidden');
        RegisterModule.resetForm();
        showScreen('register');
    };

    const openActionModalView = () => {
        appEl.classList.remove('hidden');
        showScreen('staging-modal');
    };

    const toggleMouse = () => {
        fetch(`https://${GetParentResourceName()}/actionToggleMouse`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }).catch(() => {});
    };

    const showScreen = (screenName) => {
        if (selectScreen) selectScreen.classList.add('hidden');
        if (registerScreen) registerScreen.classList.add('hidden');
        if (stagingModal) stagingModal.classList.add('hidden');
        if (confirmCityModal) confirmCityModal.classList.add('hidden');

        if (screenName === 'select') {
            if (skyBackdrop) skyBackdrop.classList.remove('hidden');
            if (selectScreen) selectScreen.classList.remove('hidden');
        } else if (screenName === 'register') {
            if (skyBackdrop) skyBackdrop.classList.remove('hidden');
            if (registerScreen) registerScreen.classList.remove('hidden');
        } else if (screenName === 'staging-modal') {
            if (skyBackdrop) skyBackdrop.classList.add('hidden');
            if (stagingModal) stagingModal.classList.remove('hidden');
        } else if (screenName === 'confirm-city') {
            if (skyBackdrop) skyBackdrop.classList.add('hidden');
            if (confirmCityModal) confirmCityModal.classList.remove('hidden');
        }
    };

    const close = () => {
        if (appEl) appEl.classList.add('hidden');
        if (selectScreen) selectScreen.classList.add('hidden');
        if (registerScreen) registerScreen.classList.add('hidden');
        if (stagingModal) stagingModal.classList.add('hidden');
        if (confirmCityModal) confirmCityModal.classList.add('hidden');
    };

    return {
        init,
        open,
        openRegisterOnly,
        openActionModalView,
        close,
        showScreen
    };
})();

document.addEventListener('DOMContentLoaded', () => {
    App.init();
});
