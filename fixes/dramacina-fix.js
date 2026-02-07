/**
 * DramaCina runtime patch (drop-in)
 *
 * Pakai:
 * 1) Pastikan file ini dimuat setelah script utama.
 * 2) Patch otomatis override `cardHTML` dan menambahkan guard `openDrama`.
 */
(function attachDramaCinaPatch() {
  if (typeof window === 'undefined') return;

  function safeJsString(value) {
    return String(value ?? '')
      .replace(/\\/g, '\\\\')
      .replace(/'/g, "\\'")
      .replace(/\"/g, '&quot;')
      .replace(/\r/g, ' ')
      .replace(/\n/g, ' ');
  }

  function isValidDramaId(id) {
    return id !== null && id !== undefined && String(id).trim() !== '';
  }

  // Expose helpers (optional untuk debugging)
  window.safeJsString = safeJsString;
  window.isValidDramaId = isValidDramaId;

  // Guard openDrama tanpa menghapus logic lama
  if (typeof window.openDrama === 'function') {
    const originalOpenDrama = window.openDrama;
    window.openDrama = async function patchedOpenDrama(id, ...rest) {
      if (!isValidDramaId(id)) {
        if (typeof window.showToast === 'function') window.showToast('ID drama tidak ditemukan');
        console.error('❌ openDrama: invalid ID:', id);
        return;
      }
      return originalOpenDrama.call(this, id, ...rest);
    };
  }

  // Override cardHTML agar aman untuk string ID dan ID kosong
  if (typeof window.cardHTML === 'function') {
    window.cardHTML = function patchedCardHTML(d) {
      const id = typeof window.getId === 'function' ? window.getId(d) : '';
      const title = typeof window.getTitle === 'function' ? window.getTitle(d) : 'Untitled';
      const poster = typeof window.getPoster === 'function' ? window.getPoster(d) : '';
      const hot = typeof window.getHotNum === 'function' ? window.getHotNum(d) : '';
      const eps = typeof window.getEpCount === 'function' ? window.getEpCount(d) : '';
      const tags = typeof window.getGenres === 'function' ? window.getGenres(d) : [];

      const validId = isValidDramaId(id);
      const safeId = safeJsString(id);

      const clickAttr = validId
        ? `onclick="openDrama('${safeId}')"`
        : `onclick="showToast('ID drama tidak ditemukan')" style="cursor:not-allowed;opacity:.85"`;

      return `
        <div class="drama-card" ${clickAttr}>
          <div class="card-poster">
            <img src="${poster}" alt="${window.esc ? window.esc(title) : title}" loading="lazy"
                 onerror="this.src='https://placehold.co/300x450/1a1a2e/666?text=No+Image'">
            <div class="card-badge">
              ${eps ? `<span class="badge-eps"><i class="fas fa-play"></i> ${eps} Ep</span>` : ''}
              ${hot ? `<span class="badge-rating"><i class="fas fa-fire"></i> ${window.formatNumber ? window.formatNumber(hot) : hot}</span>` : ''}
            </div>
            <div class="card-overlay">
              <div class="play-icon"><i class="fas fa-play"></i></div>
            </div>
          </div>
          <div class="card-info">
            <h3 class="card-title">${window.esc ? window.esc(title) : title}</h3>
            <p class="card-sub">
              ${eps ? `<span><i class="fas fa-film"></i> ${eps} Episode</span>` : ''}
              ${hot ? `<span><i class="fas fa-fire"></i> ${window.formatNumber ? window.formatNumber(hot) : hot}</span>` : ''}
            </p>
            ${Array.isArray(tags) && tags.length ? `<p class="card-tags">${tags.slice(0, 2).map(t => (window.esc ? window.esc(t) : String(t))).join(' · ')}</p>` : ''}
          </div>
        </div>
      `;
    };
  }

  console.log('✅ DramaCina patch terpasang: cardHTML + openDrama guard');
})();
