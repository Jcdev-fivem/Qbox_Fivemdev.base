// Register Module
const RegisterModule = (() => {
    const form = document.getElementById('register-form');
    const firstName = document.getElementById('reg-firstname');
    const lastName = document.getElementById('reg-lastname');
    const birthDate = document.getElementById('reg-birthdate');
    const height = document.getElementById('reg-height');
    const errorMsg = document.getElementById('register-error');
    const backBtn = document.getElementById('reg-back-btn');

    const init = () => {
        form.addEventListener('submit', onSubmit);
        if (backBtn) {
            backBtn.addEventListener('click', onBack);
        }

        // Auto-format Date of Birth (DD/MM/YYYY)
        birthDate.addEventListener('input', (e) => {
            let v = e.target.value.replace(/\D/g, '');
            if (v.length > 2 && v.length <= 4) {
                v = v.slice(0, 2) + '/' + v.slice(2);
            } else if (v.length > 4) {
                v = v.slice(0, 2) + '/' + v.slice(2, 4) + '/' + v.slice(4, 8);
            }
            e.target.value = v;
        });
    };

    const onSubmit = (e) => {
        e.preventDefault();
        errorMsg.classList.add('hidden');
        errorMsg.innerText = '';

        const fn = firstName.value.trim();
        const ln = lastName.value.trim();
        const dob = birthDate.value.trim();
        const ht = height.value.trim();
        const gender = document.querySelector('input[name="gender"]:checked').value;

        if (!fn || !ln) {
            showError('กรุณากรอกชื่อและนามสกุลให้ครบถ้วน');
            return;
        }

        if (dob.length < 10) {
            showError('รูปแบบวันเกิดต้องเป็น วว/ดด/ปปปป (เช่น 01/01/2000)');
            return;
        }

        SoundManager.play('click');

        const submitBtn = document.getElementById('reg-submit-btn');
        if (submitBtn) {
            submitBtn.disabled = true;
            submitBtn.innerText = 'CREATING...';
        }

        // Post to client Lua
        fetch(`https://${GetParentResourceName()}/submitRegister`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                firstname: fn,
                lastname: ln,
                birthdate: dob,
                height: ht || '175cm',
                gender: parseInt(gender)
            })
        }).then(res => res.json()).then(response => {
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerText = 'CREATE';
            }
            if (response && response.success) {
                // Success! Transition to Skin Creator
                SoundManager.play('success');
                App.close();
            } else {
                showError(response.message || 'ไม่สามารถสร้างตัวละครได้ กรุณาลองใหม่อีกครั้ง');
            }
        }).catch(() => {
            if (submitBtn) {
                submitBtn.disabled = false;
                submitBtn.innerText = 'CREATE';
            }
            showError('Connection failed. Please try again.');
        });
    };

    const onBack = () => {
        SoundManager.play('click');
        App.showScreen('select');
    };

    const showError = (msg) => {
        errorMsg.innerText = msg;
        errorMsg.classList.remove('hidden');
    };

    const resetForm = () => {
        form.reset();
        errorMsg.classList.add('hidden');
    };

    return {
        init,
        resetForm
    };
})();
