const passwordInput = document.querySelector("#password");
const revealButton = document.querySelector("#reveal-password");
const loginForm = document.querySelector("#login-form");
const loginStatus = document.querySelector("#login-status");
const statusText = document.querySelector("#status-text");

const userTrigger = document.querySelector("#user-trigger");
const userMenu = document.querySelector("#user-menu");
const activeUserName = document.querySelector("#active-user-name");
const avatarFallback = document.querySelector("#avatar-fallback");
const greeting = document.querySelector("#greeting");

const sessionTrigger = document.querySelector("#session-trigger");
const sessionMenu = document.querySelector("#session-menu");
const activeSession = document.querySelector("#active-session");

const clock = document.querySelector("#clock");
const date = document.querySelector("#date");

const powerDialog = document.querySelector("#power-dialog");
const powerTitle = document.querySelector("#power-title");
const powerDescription = document.querySelector("#power-description");

let activeMenu = null;
let renderedDate = "";
let renderedGreeting = "";

const powerCopy = {
    sleep: ["进入睡眠？", "后台任务可能会暂停。"],
    restart: ["重启设备？", "未保存的工作可能会受到影响。"],
    power: ["关闭设备？", "未保存的工作可能会受到影响。"]
};

function setStatus(message, state = "default") {
    loginStatus.dataset.state = state;
    statusText.textContent = message;
}

function updateClock() {
    const now = new Date();
    const hour = now.getHours();
    const hours = String(now.getHours()).padStart(2, "0");
    const minutes = String(now.getMinutes()).padStart(2, "0");
    const dateText = now.toLocaleDateString("zh-CN", {
        weekday: "long",
        month: "long",
        day: "numeric"
    });
    const greetingText = hour >= 5 && hour < 11
        ? "早上好"
        : hour >= 11 && hour < 13
            ? "中午好"
            : hour >= 13 && hour < 18
                ? "下午好"
                : hour >= 18 && hour < 23
                    ? "晚上好"
                    : "夜深了";

    clock.textContent = `${hours}:${minutes}`;
    clock.dateTime = now.toISOString();

    if (dateText !== renderedDate) {
        renderedDate = dateText;
        date.textContent = dateText;
    }

    if (greetingText !== renderedGreeting) {
        renderedGreeting = greetingText;
        greeting.textContent = greetingText;
    }
}

function setMenuState(trigger, menu, isOpen) {
    menu.classList.toggle("is-open", isOpen);
    menu.setAttribute("aria-hidden", String(!isOpen));
    menu.inert = !isOpen;
    trigger.setAttribute("aria-expanded", String(isOpen));
}

function closeMenus() {
    if (!activeMenu) {
        return;
    }

    const { trigger, menu } = activeMenu;
    setMenuState(trigger, menu, false);
    activeMenu = null;
}

function openMenu(trigger, menu) {
    closeMenus();
    setMenuState(trigger, menu, true);
    activeMenu = { trigger, menu };

    const selectedOption = menu.querySelector('[aria-checked="true"]');
    selectedOption?.focus({ preventScroll: true });
}

function toggleMenu(trigger, menu) {
    if (activeMenu?.menu === menu) {
        closeMenus();
        trigger.focus({ preventScroll: true });
    } else {
        openMenu(trigger, menu);
    }
}

function moveMenuFocus(menu, direction) {
    const options = [...menu.querySelectorAll(".menu-option")];
    const currentIndex = options.indexOf(document.activeElement);
    const nextIndex = direction === "first"
        ? 0
        : direction === "last"
            ? options.length - 1
            : (currentIndex + direction + options.length) % options.length;

    options[nextIndex]?.focus({ preventScroll: true });
}

function bindMenu(trigger, menu, { openKey, optionSelector, onSelect }) {
    trigger.addEventListener("click", () => {
        toggleMenu(trigger, menu);
    });

    trigger.addEventListener("keydown", (event) => {
        if (event.key === openKey && !activeMenu) {
            event.preventDefault();
            openMenu(trigger, menu);
        }
    });

    menu.addEventListener("keydown", (event) => {
        if (event.key === "ArrowDown") {
            event.preventDefault();
            moveMenuFocus(menu, 1);
        } else if (event.key === "ArrowUp") {
            event.preventDefault();
            moveMenuFocus(menu, -1);
        } else if (event.key === "Home") {
            event.preventDefault();
            moveMenuFocus(menu, "first");
        } else if (event.key === "End") {
            event.preventDefault();
            moveMenuFocus(menu, "last");
        } else if (event.key === "Tab") {
            closeMenus();
        }
    });

    menu.addEventListener("click", (event) => {
        const option = event.target.closest(optionSelector);
        if (!option) {
            return;
        }

        menu.querySelectorAll(optionSelector).forEach((item) => {
            item.setAttribute("aria-checked", String(item === option));
        });
        onSelect(option);
        closeMenus();
        trigger.focus({ preventScroll: true });
        setStatus("");
    });
}

bindMenu(userTrigger, userMenu, {
    openKey: "ArrowDown",
    optionSelector: ".user-option",
    onSelect(option) {
        activeUserName.textContent = option.dataset.user;
        avatarFallback.textContent = option.dataset.user.charAt(0).toUpperCase();
        avatarFallback.setAttribute("aria-label", `${option.dataset.user} 的头像`);
    }
});

bindMenu(sessionTrigger, sessionMenu, {
    openKey: "ArrowUp",
    optionSelector: ".session-option",
    onSelect(option) {
        activeSession.textContent = option.dataset.session;
    }
});

document.addEventListener("click", (event) => {
    if (
        activeMenu &&
        !activeMenu.menu.contains(event.target) &&
        !activeMenu.trigger.contains(event.target)
    ) {
        closeMenus();
    }
});

document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && activeMenu) {
        const trigger = activeMenu.trigger;
        closeMenus();
        trigger.focus({ preventScroll: true });
    }
});

revealButton.addEventListener("click", () => {
    const isRevealed = passwordInput.type === "text";
    passwordInput.type = isRevealed ? "password" : "text";
    revealButton.classList.toggle("is-visible", !isRevealed);
    revealButton.setAttribute("aria-label", isRevealed ? "显示密码" : "隐藏密码");
    revealButton.setAttribute("aria-pressed", String(!isRevealed));
    passwordInput.focus();
});

passwordInput.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
        passwordInput.value = "";
        setStatus("");
    }
});

loginForm.addEventListener("submit", (event) => {
    event.preventDefault();

    if (passwordInput.value === "") {
        setStatus("请输入密码。", "error");
        passwordInput.focus();
        return;
    }

    setStatus("");
});

document.querySelectorAll("[data-power]").forEach((button) => {
    button.addEventListener("click", () => {
        const [title, description] = powerCopy[button.dataset.power];
        powerTitle.textContent = title;
        powerDescription.textContent = description;
        powerDialog.showModal();
    });
});

powerDialog.addEventListener("click", (event) => {
    if (event.target !== powerDialog) {
        return;
    }

    const bounds = powerDialog.getBoundingClientRect();
    const clickedOutside =
        event.clientX < bounds.left ||
        event.clientX > bounds.right ||
        event.clientY < bounds.top ||
        event.clientY > bounds.bottom;

    if (clickedOutside) {
        powerDialog.close();
    }
});

updateClock();
window.setInterval(updateClock, 1000);
