import Cocoa
import UniformTypeIdentifiers

class DropView: NSView {
    private var isHighlighted = false
    private let label = NSTextField(labelWithString: "Перетащите приложение сюда для добавления в Launchpad")
    private let statusLabel = NSTextField(labelWithString: "")
    private let addButton = NSButton(title: "Добавить в Launchpad", target: nil, action: nil)
    private let removeButton = NSButton(title: "Удалить из Launchpad", target: nil, action: nil)
    private let backButton = NSButton(title: "Назад", target: nil, action: nil)
    private var selectButton: NSButton!
    private var selectedAppPath: String?
    private var appNameLabel = NSTextField(labelWithString: "")
    private var appIconView = NSImageView()
    private var dropZoneView: NSView!
    private var progressIndicator: NSProgressIndicator!
    private var buttonContainer: NSView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // Регистрация для принятия перетаскиваемых файлов
        registerForDraggedTypes([.fileURL])
        
        // Настройка внешнего вида
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        
        // Создаем фоновый вид с эффектом размытия
        let backgroundView = NSVisualEffectView(frame: bounds)
        backgroundView.material = .menu
        backgroundView.state = .active
        backgroundView.blendingMode = .behindWindow
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 20
        addSubview(backgroundView)
        
        // Создаем зону для перетаскивания
        let dropZoneSize = NSSize(width: bounds.width - 40, height: bounds.height - 120)
        dropZoneView = NSView(frame: NSRect(
            x: (bounds.width - dropZoneSize.width) / 2,
            y: 70,
            width: dropZoneSize.width,
            height: dropZoneSize.height
        ))
        dropZoneView.wantsLayer = true
        dropZoneView.layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.08).cgColor
        dropZoneView.layer?.cornerRadius = 16
        dropZoneView.layer?.borderWidth = 2
        dropZoneView.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.2).cgColor
        
        // Добавляем тень для зоны перетаскивания
        dropZoneView.shadow = NSShadow()
        dropZoneView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.1)
        dropZoneView.shadow?.shadowOffset = NSSize(width: 0, height: -2)
        dropZoneView.shadow?.shadowBlurRadius = 4
        
        addSubview(dropZoneView)
        
        // Настройка лейбла с инструкцией
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = NSColor.labelColor
        label.isEditable = false
        label.isSelectable = false
        label.drawsBackground = false
        label.isBezeled = false
        
        // Добавляем тень к тексту для лучшей читаемости
        let labelShadow = NSShadow()
        labelShadow.shadowColor = NSColor.black.withAlphaComponent(0.2)
        labelShadow.shadowOffset = NSSize(width: 0, height: 1)
        labelShadow.shadowBlurRadius = 1
        label.shadow = labelShadow
        
        dropZoneView.addSubview(label)
        
        // Добавляем иконку перетаскивания
        let dragIcon = NSImageView(frame: NSRect(x: 0, y: 0, width: 48, height: 48))
        if let dragImage = NSImage(named: NSImage.Name("NSTouchBarDownloadTemplate")) {
            dragIcon.image = dragImage
            dragIcon.contentTintColor = NSColor.secondaryLabelColor
            dragIcon.imageScaling = .scaleProportionallyUpOrDown
        }
        dropZoneView.addSubview(dragIcon)
        
        // Настройка лейбла статуса
        statusLabel.alignment = .center
        statusLabel.font = NSFont.systemFont(ofSize: 14)
        statusLabel.textColor = NSColor.secondaryLabelColor
        statusLabel.isEditable = false
        statusLabel.isSelectable = false
        statusLabel.drawsBackground = false
        statusLabel.isBezeled = false
        
        // Добавляем небольшую тень для лучшей читаемости
        let statusShadow = NSShadow()
        statusShadow.shadowColor = NSColor.black.withAlphaComponent(0.1)
        statusShadow.shadowOffset = NSSize(width: 0, height: 1)
        statusShadow.shadowBlurRadius = 0.5
        statusLabel.shadow = statusShadow
        
        addSubview(statusLabel)
        
        // Настройка лейбла с именем приложения
        appNameLabel.alignment = .center
        appNameLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        appNameLabel.textColor = NSColor.labelColor
        appNameLabel.isEditable = false
        appNameLabel.isSelectable = false
        appNameLabel.drawsBackground = false
        appNameLabel.isBezeled = false
        appNameLabel.isHidden = true
        
        // Добавляем тень к тексту для лучшей читаемости
        let appNameShadow = NSShadow()
        appNameShadow.shadowColor = NSColor.black.withAlphaComponent(0.2)
        appNameShadow.shadowOffset = NSSize(width: 0, height: 1)
        appNameShadow.shadowBlurRadius = 1
        appNameLabel.shadow = appNameShadow
        
        addSubview(appNameLabel)
        
        // Настройка иконки приложения
        appIconView.frame = NSRect(x: 0, y: 0, width: 64, height: 64)
        appIconView.imageScaling = .scaleProportionallyUpOrDown
        appIconView.isHidden = true
        addSubview(appIconView)
        
        // Создаем контейнер для кнопок
        buttonContainer = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 40))
        addSubview(buttonContainer)
        
        // Настройка кнопки добавления
        addButton.bezelStyle = .rounded
        addButton.controlSize = .large
        addButton.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        addButton.target = self
        addButton.action = #selector(addButtonClicked)
        addButton.isHidden = true
        addButton.wantsLayer = true
        addButton.layer?.cornerRadius = 8
        
        // Стилизация кнопки добавления
        if #available(macOS 11.0, *) {
            addButton.contentTintColor = .white
            addButton.bezelColor = NSColor.systemBlue
        } else {
            addButton.attributedTitle = NSAttributedString(string: "Добавить в Launchpad", attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 14, weight: .medium)
            ])
        }
        
        buttonContainer.addSubview(addButton)
        
        // Настройка кнопки удаления
        removeButton.bezelStyle = .rounded
        removeButton.controlSize = .large
        removeButton.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        removeButton.target = self
        removeButton.action = #selector(removeButtonClicked)
        removeButton.isHidden = true
        removeButton.wantsLayer = true
        removeButton.layer?.cornerRadius = 8
        
        // Стилизация кнопки удаления
        if #available(macOS 11.0, *) {
            removeButton.contentTintColor = .white
            removeButton.bezelColor = NSColor.systemRed
        } else {
            removeButton.attributedTitle = NSAttributedString(string: "Удалить из Launchpad", attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 14, weight: .medium)
            ])
        }
        
        buttonContainer.addSubview(removeButton)
        
        // Добавляем кнопку для выбора приложения через диалог
        selectButton = NSButton(title: "Выбрать приложение", target: self, action: #selector(selectAppButtonClicked))
        selectButton.bezelStyle = .rounded
        selectButton.controlSize = .large
        selectButton.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        selectButton.wantsLayer = true
        selectButton.layer?.cornerRadius = 8
        
        // Стилизация кнопки выбора
        if #available(macOS 11.0, *) {
            selectButton.bezelColor = NSColor.controlAccentColor
            selectButton.contentTintColor = .white
        } else {
            selectButton.attributedTitle = NSAttributedString(string: "Выбрать приложение", attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 14, weight: .medium)
            ])
        }
        
        addSubview(selectButton)
        
        // Позиционируем кнопку выбора
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            selectButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            selectButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])
        
        // Добавляем кнопку "Назад"
        backButton.bezelStyle = .rounded
        backButton.controlSize = .regular
        backButton.font = NSFont.systemFont(ofSize: 12, weight: .medium)
        backButton.target = self
        backButton.action = #selector(backButtonClicked)
        backButton.isHidden = true
        backButton.wantsLayer = true
        backButton.layer?.cornerRadius = 6
        
        // Стилизация кнопки назад
        if #available(macOS 11.0, *) {
            backButton.contentTintColor = .white
            backButton.bezelColor = NSColor.systemGray
        } else {
            backButton.attributedTitle = NSAttributedString(string: "Назад", attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 12, weight: .medium)
            ])
        }
        
        addSubview(backButton)
        
        // Создаем индикатор прогресса
        progressIndicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 32, height: 32))
        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = true
        progressIndicator.isDisplayedWhenStopped = false
        progressIndicator.isHidden = true
        addSubview(progressIndicator)
        
        // Позиционируем элементы
        updateLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        updateLayout()
    }
    
    private func updateLayout() {
        // Обновляем размер и позицию фонового вида
        if let backgroundView = subviews.first as? NSVisualEffectView {
            backgroundView.frame = bounds
        }
        
        // Обновляем размер и позицию зоны для перетаскивания
        let dropZoneSize = NSSize(width: bounds.width - 40, height: bounds.height - 120)
        dropZoneView.frame = NSRect(
            x: (bounds.width - dropZoneSize.width) / 2,
            y: 70,
            width: dropZoneSize.width,
            height: dropZoneSize.height
        )
        
        // Размещаем иконку перетаскивания
        if let dragIcon = dropZoneView.subviews.first(where: { $0 is NSImageView }) as? NSImageView {
            dragIcon.frame = NSRect(
                x: (dropZoneView.bounds.width - 48) / 2,
                y: (dropZoneView.bounds.height - 48) / 2 + 20,
                width: 48,
                height: 48
            )
        }
        
        // Размещаем лейбл по центру
        let labelSize = label.intrinsicContentSize
        label.frame = NSRect(
            x: (dropZoneView.bounds.width - labelSize.width) / 2,
            y: (dropZoneView.bounds.height - labelSize.height) / 2 - 20,
            width: labelSize.width,
            height: labelSize.height
        )
        
        // Размещаем лейбл статуса под основным лейблом
        let statusSize = statusLabel.intrinsicContentSize
        statusLabel.frame = NSRect(
            x: (bounds.width - statusSize.width) / 2,
            y: 40,
            width: statusSize.width,
            height: statusSize.height
        )
        
        // Размещаем иконку приложения
        appIconView.frame = NSRect(
            x: (bounds.width - 64) / 2,
            y: bounds.height - 130,
            width: 64,
            height: 64
        )
        
        // Размещаем лейбл с именем приложения
        let appNameSize = appNameLabel.intrinsicContentSize
        appNameLabel.frame = NSRect(
            x: (bounds.width - appNameSize.width) / 2,
            y: bounds.height - 160,
            width: appNameSize.width,
            height: appNameSize.height
        )
        
        // Размещаем контейнер кнопок
        buttonContainer.frame = NSRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: bounds.height
        )
        
        // Если приложение выбрано, обновляем расположение кнопок
        if !addButton.isHidden {
            updateButtonLayout()
        }
        
        // Размещаем индикатор прогресса
        progressIndicator.frame = NSRect(
            x: (bounds.width - 32) / 2,
            y: bounds.height / 2 - 16,
            width: 32,
            height: 32
        )
    }
    
    private func updateButtonLayout() {
        // Получаем размеры кнопок
        let buttonWidth: CGFloat = 180
        let buttonHeight: CGFloat = 32
        let margin: CGFloat = 30
        
        // Размещаем кнопку добавления в левой части
        addButton.frame = NSRect(
            x: margin,
            y: bounds.height / 2 - buttonHeight / 2,
            width: buttonWidth,
            height: buttonHeight
        )
        
        // Размещаем кнопку удаления в правой части
        removeButton.frame = NSRect(
            x: bounds.width - buttonWidth - margin,
            y: bounds.height / 2 - buttonHeight / 2,
            width: buttonWidth,
            height: buttonHeight
        )
        
        // Размещаем кнопку назад в правом верхнем углу
        let backButtonWidth: CGFloat = 80
        let backButtonHeight: CGFloat = 24
        backButton.frame = NSRect(
            x: bounds.width - backButtonWidth - 10,
            y: bounds.height - backButtonHeight - 10,
            width: backButtonWidth,
            height: backButtonHeight
        )
    }
    
    @objc private func selectAppButtonClicked() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.allowedContentTypes = [UTType(filenameExtension: "app", conformingTo: .package)!]
        openPanel.message = "Выберите приложение для добавления в Launchpad"
        openPanel.prompt = "Выбрать"
        
        openPanel.begin { [weak self] (result) in
            if result == .OK, let url = openPanel.url {
                self?.handleSelectedApp(url)
            }
        }
    }
    
    @objc private func addButtonClicked() {
        guard let appPath = selectedAppPath else { return }
        addToLaunchpad(URL(fileURLWithPath: appPath))
    }
    
    @objc private func removeButtonClicked() {
        guard let appPath = selectedAppPath else { return }
        removeFromLaunchpad(URL(fileURLWithPath: appPath))
    }
    
    @objc private func backButtonClicked() {
        resetUI()
    }
    
    private func handleSelectedApp(_ url: URL) {
        selectedAppPath = url.path
        appNameLabel.stringValue = url.lastPathComponent
        appNameLabel.isHidden = false
        addButton.isHidden = false
        removeButton.isHidden = false
        dropZoneView.isHidden = true
        selectButton.isHidden = true
        backButton.isHidden = false
        
        // Загружаем иконку приложения
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        appIconView.image = icon
        appIconView.isHidden = false
        
        // Обновляем размеры лейбла
        let appNameSize = appNameLabel.intrinsicContentSize
        appNameLabel.frame = NSRect(
            x: (bounds.width - appNameSize.width) / 2,
            y: bounds.height - 160,
            width: appNameSize.width,
            height: appNameSize.height
        )
        
        // Размещаем кнопки в правильных позициях
        updateButtonLayout()
        
        needsLayout = true
    }
    
    // MARK: - NSDraggingDestination
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pboard = sender.draggingPasteboard
        
        if let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           urls.contains(where: { isApplication($0) }) {
            isHighlighted = true
            
            // Анимируем изменение цвета границы и фона
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                dropZoneView.layer?.borderColor = NSColor.systemBlue.cgColor
                dropZoneView.layer?.backgroundColor = NSColor.systemBlue.withAlphaComponent(0.08).cgColor
                
                // Увеличиваем тень
                dropZoneView.shadow?.shadowBlurRadius = 8
            })
            
            return .copy
        }
        
        return []
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isHighlighted = false
        
        // Анимируем возвращение к исходному состоянию
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            dropZoneView.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.2).cgColor
            dropZoneView.layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.08).cgColor
            
            // Возвращаем тень к исходному состоянию
            dropZoneView.shadow?.shadowBlurRadius = 4
        })
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        
        if let urls = pboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            for url in urls {
                if isApplication(url) {
                    handleSelectedApp(url)
                    return true
                }
            }
        }
        
        return false
    }
    
    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        isHighlighted = false
        
        // Анимируем возвращение к исходному состоянию
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            dropZoneView.layer?.borderColor = NSColor.lightGray.withAlphaComponent(0.2).cgColor
            dropZoneView.layer?.backgroundColor = NSColor(calibratedWhite: 1.0, alpha: 0.08).cgColor
            
            // Возвращаем тень к исходному состоянию
            dropZoneView.shadow?.shadowBlurRadius = 4
        })
    }
    
    // MARK: - Helper Methods
    
    private func isApplication(_ url: URL) -> Bool {
        return url.pathExtension == "app"
    }
    
    private func addToLaunchpad(_ appURL: URL) {
        statusLabel.stringValue = "Добавление \(appURL.lastPathComponent) в Launchpad..."
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        // Создаем символическую ссылку в /Applications если приложение находится на внешнем диске
        let targetPath = "/Applications/\(appURL.lastPathComponent)"
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Проверяем, существует ли уже ссылка или приложение с таким именем
                if !FileManager.default.fileExists(atPath: targetPath) {
                    try FileManager.default.createSymbolicLink(atPath: targetPath, withDestinationPath: appURL.path)
                    
                    // Перезапускаем Dock для обновления Launchpad
                    let dockTask = Process()
                    dockTask.launchPath = "/usr/bin/killall"
                    dockTask.arguments = ["Dock"]
                    dockTask.launch()
                    
                    DispatchQueue.main.async {
                        self.progressIndicator.stopAnimation(nil)
                        self.progressIndicator.isHidden = true
                        self.statusLabel.stringValue = "Приложение \(appURL.lastPathComponent) успешно добавлено в Launchpad!"
                        
                        // Анимация успешного добавления
                        self.animateSuccess()
                        
                        // Возвращаем статус к исходному через 3 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.statusLabel.stringValue = ""
                            self.resetUI()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.progressIndicator.stopAnimation(nil)
                        self.progressIndicator.isHidden = true
                        self.statusLabel.stringValue = "Приложение или ссылка с таким именем уже существует в /Applications"
                        
                        // Возвращаем статус к исходному через 3 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.statusLabel.stringValue = ""
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.progressIndicator.stopAnimation(nil)
                    self.progressIndicator.isHidden = true
                    self.statusLabel.stringValue = "Ошибка: \(error.localizedDescription)"
                    
                    // Возвращаем статус к исходному через 5 секунд
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.statusLabel.stringValue = ""
                    }
                }
            }
        }
    }
    
    private func removeFromLaunchpad(_ appURL: URL) {
        statusLabel.stringValue = "Удаление \(appURL.lastPathComponent) из Launchpad..."
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        // Проверяем, есть ли символическая ссылка в /Applications
        let targetPath = "/Applications/\(appURL.lastPathComponent)"
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var isSymlink = false
                var symlinkDestination = ""
                
                if FileManager.default.fileExists(atPath: targetPath) {
                    // Проверяем, является ли это символической ссылкой
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: targetPath),
                       let fileType = attributes[.type] as? String,
                       fileType == FileAttributeType.typeSymbolicLink.rawValue {
                        isSymlink = true
                        symlinkDestination = try FileManager.default.destinationOfSymbolicLink(atPath: targetPath)
                    }
                    
                    // Удаляем символическую ссылку, если она указывает на наше приложение
                    if isSymlink && symlinkDestination == appURL.path {
                        try FileManager.default.removeItem(atPath: targetPath)
                        
                        // Перезапускаем Dock для обновления Launchpad
                        let dockTask = Process()
                        dockTask.launchPath = "/usr/bin/killall"
                        dockTask.arguments = ["Dock"]
                        dockTask.launch()
                        
                        DispatchQueue.main.async {
                            self.progressIndicator.stopAnimation(nil)
                            self.progressIndicator.isHidden = true
                            self.statusLabel.stringValue = "Приложение \(appURL.lastPathComponent) успешно удалено из Launchpad!"
                            
                            // Анимация успешного удаления
                            self.animateSuccess()
                            
                            // Возвращаем статус к исходному через 3 секунды
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.statusLabel.stringValue = ""
                                self.resetUI()
                            }
                        }
                    } else if isSymlink {
                        DispatchQueue.main.async {
                            self.progressIndicator.stopAnimation(nil)
                            self.progressIndicator.isHidden = true
                            self.statusLabel.stringValue = "Символическая ссылка указывает на другое приложение"
                            
                            // Возвращаем статус к исходному через 3 секунды
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.statusLabel.stringValue = ""
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.progressIndicator.stopAnimation(nil)
                            self.progressIndicator.isHidden = true
                            self.statusLabel.stringValue = "Это не символическая ссылка, а реальное приложение"
                            
                            // Возвращаем статус к исходному через 3 секунды
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.statusLabel.stringValue = ""
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.progressIndicator.stopAnimation(nil)
                        self.progressIndicator.isHidden = true
                        self.statusLabel.stringValue = "Приложение не найдено в /Applications"
                        
                        // Возвращаем статус к исходному через 3 секунды
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.statusLabel.stringValue = ""
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.progressIndicator.stopAnimation(nil)
                    self.progressIndicator.isHidden = true
                    self.statusLabel.stringValue = "Ошибка: \(error.localizedDescription)"
                    
                    // Возвращаем статус к исходному через 5 секунд
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.statusLabel.stringValue = ""
                    }
                }
            }
        }
    }
    
    private func animateSuccess() {
        // Создаем анимацию для индикации успешного выполнения
        let successView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        successView.material = .hudWindow
        successView.state = .active
        successView.wantsLayer = true
        successView.layer?.cornerRadius = 50
        
        // Добавляем внутренний круг
        let innerCircle = NSView(frame: NSRect(x: 15, y: 15, width: 70, height: 70))
        innerCircle.wantsLayer = true
        innerCircle.layer?.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.3).cgColor
        innerCircle.layer?.cornerRadius = 35
        successView.addSubview(innerCircle)
        
        // Добавляем иконку галочки
        let checkmarkImage = NSImageView(frame: NSRect(x: 25, y: 25, width: 50, height: 50))
        if let image = NSImage(named: NSImage.Name("NSStatusAvailable")) {
            checkmarkImage.image = image
            checkmarkImage.contentTintColor = NSColor.systemGreen
        }
        successView.addSubview(checkmarkImage)
        
        successView.frame = NSRect(
            x: (bounds.width - 100) / 2,
            y: (bounds.height - 100) / 2,
            width: 100,
            height: 100
        )
        
        addSubview(successView)
        
        // Добавляем тень
        successView.shadow = NSShadow()
        successView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.3)
        successView.shadow?.shadowOffset = NSSize(width: 0, height: -3)
        successView.shadow?.shadowBlurRadius = 10
        
        // Анимируем появление и исчезновение
        successView.alphaValue = 0
        
        // Устанавливаем начальное состояние для анимации
        let initialTransform = CATransform3DMakeScale(0.5, 0.5, 1.0)
        successView.layer?.transform = initialTransform
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            successView.animator().alphaValue = 1
            
            // Анимируем трансформацию через Core Animation
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = initialTransform
            animation.toValue = CATransform3DIdentity
            animation.duration = 0.4
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            successView.layer?.add(animation, forKey: "transform")
            successView.layer?.transform = CATransform3DIdentity
            
        }, completionHandler: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.3
                    context.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    successView.animator().alphaValue = 0
                    
                    // Анимируем трансформацию через Core Animation
                    let animation = CABasicAnimation(keyPath: "transform")
                    animation.fromValue = CATransform3DIdentity
                    animation.toValue = CATransform3DMakeScale(0.8, 0.8, 1.0)
                    animation.duration = 0.3
                    animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                    successView.layer?.add(animation, forKey: "transform")
                    successView.layer?.transform = CATransform3DMakeScale(0.8, 0.8, 1.0)
                    
                }, completionHandler: {
                    successView.removeFromSuperview()
                })
            }
        })
    }
    
    private func resetUI() {
        selectedAppPath = nil
        appNameLabel.isHidden = true
        appIconView.isHidden = true
        addButton.isHidden = true
        removeButton.isHidden = true
        backButton.isHidden = true
        dropZoneView.isHidden = false
        selectButton.isHidden = false
    }
} 