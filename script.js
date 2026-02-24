// 想法记录本应用
class NotebookApp {
    constructor() {
        this.notes = [];
        this.currentNoteId = null;
        this.init();
    }

    init() {
        this.loadNotes();
        this.setupEventListeners();
        this.renderNotes();
        this.updateStats();
    }

    // 从localStorage加载笔记
    loadNotes() {
        const savedNotes = localStorage.getItem('notebook-notes');
        if (savedNotes) {
            this.notes = JSON.parse(savedNotes);
        }
    }

    // 保存笔记到localStorage
    saveNotes() {
        localStorage.setItem('notebook-notes', JSON.stringify(this.notes));
    }

    // 设置事件监听器
    setupEventListeners() {
        // 添加笔记按钮
        document.getElementById('add-note-btn').addEventListener('click', () => this.addNote());
        
        // 搜索功能
        document.getElementById('search-notes').addEventListener('input', (e) => this.filterNotes(e.target.value));
        
        // 清空所有记录
        document.getElementById('clear-all-btn').addEventListener('click', () => this.clearAllNotes());
        
        // 模态框按钮
        document.getElementById('confirm-delete-btn').addEventListener('click', () => this.confirmDelete());
        document.getElementById('cancel-delete-btn').addEventListener('click', () => this.hideDeleteModal());
        
        // 按Enter键添加笔记
        document.getElementById('note-content').addEventListener('keydown', (e) => {
            if (e.ctrlKey && e.key === 'Enter') {
                this.addNote();
            }
        });
    }

    // 添加新笔记
    addNote() {
        const title = document.getElementById('note-title').value.trim();
        const content = document.getElementById('note-content').value.trim();
        const tagsInput = document.getElementById('note-tags').value.trim();
        
        if (!content) {
            alert('请填写想法内容！');
            return;
        }
        
        const tags = tagsInput ? tagsInput.split(',').map(tag => tag.trim()).filter(tag => tag) : [];
        
        const newNote = {
            id: Date.now(),
            title: title || '未命名想法',
            content: content,
            tags: tags,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };
        
        this.notes.unshift(newNote);
        this.saveNotes();
        this.renderNotes();
        this.updateStats();
        this.clearForm();
        
        // 显示成功提示
        this.showNotification('想法已保存！', 'success');
    }

    // 清空表单
    clearForm() {
        document.getElementById('note-title').value = '';
        document.getElementById('note-content').value = '';
        document.getElementById('note-tags').value = '';
        document.getElementById('note-content').focus();
    }

    // 删除笔记
    deleteNote(id) {
        this.currentNoteId = id;
        this.showDeleteModal();
    }

    // 显示删除确认模态框
    showDeleteModal() {
        document.getElementById('delete-modal').style.display = 'flex';
    }

    // 隐藏删除确认模态框
    hideDeleteModal() {
        document.getElementById('delete-modal').style.display = 'none';
        this.currentNoteId = null;
    }

    // 确认删除
    confirmDelete() {
        if (this.currentNoteId) {
            this.notes = this.notes.filter(note => note.id !== this.currentNoteId);
            this.saveNotes();
            this.renderNotes();
            this.updateStats();
            this.showNotification('想法已删除！', 'info');
        }
        this.hideDeleteModal();
    }

    // 清空所有笔记
    clearAllNotes() {
        if (this.notes.length === 0) {
            this.showNotification('没有可清空的记录！', 'info');
            return;
        }
        
        if (confirm('确定要清空所有想法记录吗？此操作不可撤销！')) {
            this.notes = [];
            this.saveNotes();
            this.renderNotes();
            this.updateStats();
            this.showNotification('所有记录已清空！', 'info');
        }
    }

    // 过滤笔记
    filterNotes(searchTerm) {
        const filteredNotes = searchTerm ? 
            this.notes.filter(note => 
                note.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
                note.content.toLowerCase().includes(searchTerm.toLowerCase()) ||
                note.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase()))
            ) : 
            this.notes;
        
        this.renderNotes(filteredNotes);
    }

    // 渲染笔记列表
    renderNotes(notesToRender = this.notes) {
        const container = document.getElementById('notes-container');
        
        if (notesToRender.length === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <i class="fas fa-lightbulb"></i>
                    <p>没有找到匹配的想法记录</p>
                    <p>尝试不同的搜索词或添加新想法</p>
                </div>
            `;
            return;
        }
        
        container.innerHTML = notesToRender.map(note => this.createNoteHTML(note)).join('');
        
        // 为每个删除按钮添加事件监听器
        notesToRender.forEach(note => {
            const deleteBtn = document.getElementById(`delete-btn-${note.id}`);
            if (deleteBtn) {
                deleteBtn.addEventListener('click', () => this.deleteNote(note.id));
            }
        });
        
        this.updateTagFilter();
    }

    // 创建单个笔记的HTML
    createNoteHTML(note) {
        const date = new Date(note.createdAt);
        const formattedDate = date.toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
        
        const tagsHTML = note.tags.map(tag => 
            `<span class="tag">${this.escapeHTML(tag)}</span>`
        ).join('');
        
        return `
            <div class="note-card" data-id="${note.id}">
                <div class="note-header">
                    <h3 class="note-title">${this.escapeHTML(note.title)}</h3>
                    <span class="note-date">${formattedDate}</span>
                </div>
                <div class="note-content">${this.formatContent(note.content)}</div>
                ${note.tags.length > 0 ? `<div class="note-tags">${tagsHTML}</div>` : ''}
                <div class="note-actions">
                    <button id="delete-btn-${note.id}" class="delete-btn" title="删除想法">
                        <i class="fas fa-trash"></i> 删除
                    </button>
                </div>
            </div>
        `;
    }

    // 格式化内容（保留换行）
    formatContent(content) {
        return this.escapeHTML(content).replace(/\n/g, '<br>');
    }

    // 防止XSS攻击
    escapeHTML(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // 更新标签过滤器
    updateTagFilter() {
        const allTags = new Set();
        this.notes.forEach(note => {
            note.tags.forEach(tag => allTags.add(tag));
        });
        
        const filterSelect = document.getElementById('filter-tags');
        const currentValue = filterSelect.value;
        
        // 清空选项（保留"所有标签"）
        filterSelect.innerHTML = '<option value="">所有标签</option>';
        
        // 添加标签选项
        Array.from(allTags).sort().forEach(tag => {
            const option = document.createElement('option');
            option.value = tag;
            option.textContent = tag;
            filterSelect.appendChild(option);
        });
        
        // 恢复之前的选择
        filterSelect.value = currentValue;
        
        // 添加标签过滤事件
        filterSelect.onchange = (e) => {
            const selectedTag = e.target.value;
            if (selectedTag) {
                const filteredNotes = this.notes.filter(note => 
                    note.tags.includes(selectedTag)
                );
                this.renderNotes(filteredNotes);
            } else {
                this.renderNotes();
            }
        };
    }

    // 更新统计信息
    updateStats() {
        document.getElementById('total-notes').textContent = this.notes.length;
    }

    // 显示通知
    showNotification(message, type = 'info') {
        // 移除现有的通知
        const existingNotification = document.querySelector('.notification');
        if (existingNotification) {
            existingNotification.remove();
        }
        
        // 创建新通知
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <i class="fas fa-${type === 'success' ? 'check-circle' : 'info-circle'}"></i>
            <span>${message}</span>
        `;
        
        // 添加样式
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#48bb78' : '#4299e1'};
            color: white;
            padding: 15px 20px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
            z-index: 1001;
            animation: slideIn 0.3s ease-out;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        `;
        
        // 添加动画
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
        `;
        document.head.appendChild(style);
        
        document.body.appendChild(notification);
        
        // 3秒后自动移除
        setTimeout(() => {
            notification.style.animation = 'slideOut 0.3s ease-out';
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }
}

// 页面加载完成后初始化应用
document.addEventListener('DOMContentLoaded', () => {
    new NotebookApp();
    
    // 添加额外的CSS样式
    const extraStyles = document.createElement('style');
    extraStyles.textContent = `
        @keyframes slideOut {
            from { transform: translateX(0); opacity: 1; }
            to { transform: translateX(100%); opacity: 0; }
        }
        
        .notification-success {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
        }
        
        .notification-info {
            background: linear-gradient(135deg, #4299e1 0%, #3182ce 100%);
        }
    `;
    document.head.appendChild(extraStyles);
    
    // 设置焦点到内容输入框
    document.getElementById('note-content').focus();
});