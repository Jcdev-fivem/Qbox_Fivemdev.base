// Select Module
const SelectModule = (() => {
    const slotsContainer = document.getElementById('character-slots');

    const renderSlots = (characters, maxSlots = 4) => {
        slotsContainer.innerHTML = '';

        for (let i = 1; i <= maxSlots; i++) {
            const char = characters.find(c => c.cid === i) || characters[i - 1];

            const card = document.createElement('div');
            card.className = 'character-card';

            if (char) {
                // Populated Slot
                card.innerHTML = `
                    <div class="slot-badge">SLOT ${i}</div>
                    <div class="card-body">
                        <div class="char-avatar">
                            <i class="fa-solid fa-user"></i>
                        </div>
                        <div class="char-fullname">${char.firstname} ${char.lastname}</div>
                        <div class="char-meta">
                            <div class="meta-row">
                                <span class="meta-label">CITIZEN ID</span>
                                <span class="meta-value">${char.citizenid}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">JOB</span>
                                <span class="meta-value">${char.job}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">CASH</span>
                                <span class="meta-value">$${Number(char.cash || 0).toLocaleString()}</span>
                            </div>
                            <div class="meta-row">
                                <span class="meta-label">BANK</span>
                                <span class="meta-value">$${Number(char.bank || 0).toLocaleString()}</span>
                            </div>
                        </div>
                    </div>
                    <div class="card-actions">
                        <button type="button" class="btn-play">PLAY</button>
                        <button type="button" class="btn-delete" title="ลบตัวละคร"><i class="fa-solid fa-trash"></i></button>
                    </div>
                `;

                const playBtn = card.querySelector('.btn-play');
                playBtn.addEventListener('click', () => {
                    SoundManager.play('click');
                    fetch(`https://${GetParentResourceName()}/selectCharacter`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ citizenid: char.citizenid, position: char.position })
                    }).then(() => {
                        App.close();
                    });
                });

                const deleteBtn = card.querySelector('.btn-delete');
                let deleteConfirmTimeout = null;
                deleteBtn.addEventListener('click', () => {
                    SoundManager.play('click');
                    if (deleteBtn.dataset.confirming === 'true') {
                        // Confirmed deletion!
                        clearTimeout(deleteConfirmTimeout);
                        fetch(`https://${GetParentResourceName()}/deleteCharacter`, {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json' },
                            body: JSON.stringify({ citizenid: char.citizenid })
                        });
                    } else {
                        // First click: ask for confirmation
                        deleteBtn.dataset.confirming = 'true';
                        deleteBtn.innerHTML = '<i class="fa-solid fa-triangle-exclamation"></i>';
                        deleteBtn.style.background = '#ef4444';
                        deleteBtn.style.color = '#ffffff';

                        deleteConfirmTimeout = setTimeout(() => {
                            deleteBtn.dataset.confirming = 'false';
                            deleteBtn.innerHTML = '<i class="fa-solid fa-trash"></i>';
                            deleteBtn.style.background = '';
                            deleteBtn.style.color = '';
                        }, 3500);
                    }
                });

            } else {
                // Empty Slot Card
                card.classList.add('empty-slot');
                card.innerHTML = `
                    <div class="empty-slot-icon"><i class="fa-solid fa-plus"></i></div>
                    <div class="empty-slot-text">CREATE NEW</div>
                `;

                card.addEventListener('click', () => {
                    SoundManager.play('click');
                    RegisterModule.resetForm();
                    App.showScreen('register');
                });
            }

            slotsContainer.appendChild(card);
        }
    };

    return {
        renderSlots
    };
})();
