import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var dropView: DropView!
    var visualEffectView: NSVisualEffectView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создаем основное окно
        let windowSize = NSSize(width: 600, height: 450)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.title = "Launchpad Adder"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor.clear
        window.isMovableByWindowBackground = true
        window.setFrameAutosaveName("LaunchpadAdderWindow")
        
        // Устанавливаем минимальный размер окна
        window.minSize = NSSize(width: 500, height: 400)
        
        // Создаем эффект размытия для фона
        visualEffectView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height))
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        visualEffectView.blendingMode = .behindWindow
        
        // Создаем контейнер для всех элементов
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height))
        containerView.wantsLayer = true
        
        // Создаем логотип приложения
        let logoSize: CGFloat = 80
        let logoView = NSImageView(frame: NSRect(x: (windowSize.width - logoSize) / 2, y: windowSize.height - 130, width: logoSize, height: logoSize))
        
        // Создаем изображение для логотипа (используем системное изображение Launchpad)
        if let launchpadImage = NSImage(named: NSImage.Name("NSTouchBarLaunchpadTemplate")) {
            let coloredImage = NSImage(size: launchpadImage.size)
            coloredImage.lockFocus()
            NSColor.systemBlue.set()
            let imageRect = NSRect(x: 0, y: 0, width: launchpadImage.size.width, height: launchpadImage.size.height)
            imageRect.fill(using: .sourceAtop)
            launchpadImage.draw(in: imageRect)
            coloredImage.unlockFocus()
            
            logoView.image = coloredImage
            logoView.imageScaling = .scaleProportionallyUpOrDown
        }
        
        // Добавляем тень к логотипу
        logoView.shadow = NSShadow()
        logoView.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.2)
        logoView.shadow?.shadowOffset = NSSize(width: 0, height: -2)
        logoView.shadow?.shadowBlurRadius = 5
        
        // Создаем заголовок приложения
        let titleLabel = NSTextField(labelWithString: "Launchpad Adder")
        titleLabel.font = NSFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = NSColor.labelColor
        titleLabel.alignment = .center
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.drawsBackground = false
        titleLabel.isBezeled = false
        
        // Добавляем тень к заголовку для лучшей читаемости
        let titleShadow = NSShadow()
        titleShadow.shadowColor = NSColor.black.withAlphaComponent(0.2)
        titleShadow.shadowOffset = NSSize(width: 0, height: 1)
        titleShadow.shadowBlurRadius = 2
        titleLabel.shadow = titleShadow
        
        // Создаем подзаголовок
        let subtitleLabel = NSTextField(labelWithString: "Управление приложениями в Launchpad")
        subtitleLabel.font = NSFont.systemFont(ofSize: 16, weight: .light)
        subtitleLabel.textColor = NSColor.secondaryLabelColor
        subtitleLabel.alignment = .center
        subtitleLabel.isEditable = false
        subtitleLabel.isSelectable = false
        subtitleLabel.drawsBackground = false
        subtitleLabel.isBezeled = false
        
        // Добавляем тень к подзаголовку
        let subtitleShadow = NSShadow()
        subtitleShadow.shadowColor = NSColor.black.withAlphaComponent(0.1)
        subtitleShadow.shadowOffset = NSSize(width: 0, height: 1)
        subtitleShadow.shadowBlurRadius = 1
        subtitleLabel.shadow = subtitleShadow
        
        // Создаем область для перетаскивания
        dropView = DropView(frame: NSRect(x: 0, y: 0, width: windowSize.width - 80, height: windowSize.height - 200))
        
        // Создаем разделительную линию
        let separatorView = NSBox(frame: NSRect(x: 40, y: windowSize.height - 160, width: windowSize.width - 80, height: 1))
        separatorView.boxType = .separator
        separatorView.alphaValue = 0.5
        
        // Создаем подпись внизу окна с годом и автором
        let footerLabel = NSTextField(labelWithString: "© 2025 Launchpad Adder • seidenov")
        footerLabel.font = NSFont.systemFont(ofSize: 12)
        footerLabel.textColor = NSColor.tertiaryLabelColor
        footerLabel.alignment = .center
        footerLabel.isEditable = false
        footerLabel.isSelectable = false
        footerLabel.drawsBackground = false
        footerLabel.isBezeled = false
        
        // Создаем ссылку на GitHub
        let githubButton = NSButton(title: "github.com/seidenov", target: self, action: #selector(openGitHub))
        githubButton.bezelStyle = .inline
        githubButton.isBordered = false
        githubButton.font = NSFont.systemFont(ofSize: 12)
        githubButton.contentTintColor = NSColor.systemBlue
        
        // Добавляем элементы в контейнер
        containerView.addSubview(visualEffectView)
        containerView.addSubview(logoView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(separatorView)
        containerView.addSubview(dropView)
        containerView.addSubview(footerLabel)
        containerView.addSubview(githubButton)
        
        // Размещаем заголовок
        titleLabel.frame = NSRect(
            x: (windowSize.width - titleLabel.intrinsicContentSize.width) / 2,
            y: windowSize.height - 170,
            width: titleLabel.intrinsicContentSize.width,
            height: titleLabel.intrinsicContentSize.height
        )
        
        // Размещаем подзаголовок
        subtitleLabel.frame = NSRect(
            x: (windowSize.width - subtitleLabel.intrinsicContentSize.width) / 2,
            y: windowSize.height - 200,
            width: subtitleLabel.intrinsicContentSize.width,
            height: subtitleLabel.intrinsicContentSize.height
        )
        
        // Размещаем область для перетаскивания
        dropView.frame = NSRect(
            x: 40,
            y: 60,
            width: windowSize.width - 80,
            height: windowSize.height - 280
        )
        
        // Размещаем подпись внизу
        footerLabel.frame = NSRect(
            x: (windowSize.width - footerLabel.intrinsicContentSize.width) / 2,
            y: 30,
            width: footerLabel.intrinsicContentSize.width,
            height: footerLabel.intrinsicContentSize.height
        )
        
        // Размещаем кнопку GitHub
        githubButton.frame = NSRect(
            x: (windowSize.width - githubButton.intrinsicContentSize.width) / 2,
            y: 10,
            width: githubButton.intrinsicContentSize.width,
            height: githubButton.intrinsicContentSize.height
        )
        
        window.contentView = containerView
        window.makeKeyAndOrderFront(nil)
        
        // Регистрируем наблюдателя за изменением размера окна
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowDidResize),
            name: NSWindow.didResizeNotification,
            object: window
        )
    }
    
    @objc func openGitHub() {
        if let url = URL(string: "https://github.com/seidenov") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func windowDidResize(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        let windowSize = window.frame.size
        
        visualEffectView.frame = NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height)
        
        // Обновляем позиции элементов при изменении размера окна
        if let containerView = window.contentView {
            for subview in containerView.subviews {
                if let logoView = subview as? NSImageView {
                    let logoSize: CGFloat = 80
                    logoView.frame = NSRect(
                        x: (windowSize.width - logoSize) / 2,
                        y: windowSize.height - 130,
                        width: logoSize,
                        height: logoSize
                    )
                } else if let textField = subview as? NSTextField {
                    if textField.stringValue == "Launchpad Adder" {
                        textField.frame = NSRect(
                            x: (windowSize.width - textField.intrinsicContentSize.width) / 2,
                            y: windowSize.height - 170,
                            width: textField.intrinsicContentSize.width,
                            height: textField.intrinsicContentSize.height
                        )
                    } else if textField.stringValue == "Управление приложениями в Launchpad" {
                        textField.frame = NSRect(
                            x: (windowSize.width - textField.intrinsicContentSize.width) / 2,
                            y: windowSize.height - 200,
                            width: textField.intrinsicContentSize.width,
                            height: textField.intrinsicContentSize.height
                        )
                    } else if textField.stringValue.hasPrefix("©") {
                        textField.frame = NSRect(
                            x: (windowSize.width - textField.intrinsicContentSize.width) / 2,
                            y: 30,
                            width: textField.intrinsicContentSize.width,
                            height: textField.intrinsicContentSize.height
                        )
                    }
                } else if let dropView = subview as? DropView {
                    dropView.frame = NSRect(
                        x: 40,
                        y: 60,
                        width: windowSize.width - 80,
                        height: windowSize.height - 280
                    )
                } else if let separator = subview as? NSBox {
                    separator.frame = NSRect(
                        x: 40,
                        y: windowSize.height - 160,
                        width: windowSize.width - 80,
                        height: 1
                    )
                } else if let button = subview as? NSButton, button.title == "github.com/seidenov" {
                    button.frame = NSRect(
                        x: (windowSize.width - button.intrinsicContentSize.width) / 2,
                        y: 10,
                        width: button.intrinsicContentSize.width,
                        height: button.intrinsicContentSize.height
                    )
                }
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Код при завершении приложения
        NotificationCenter.default.removeObserver(self)
    }
} 