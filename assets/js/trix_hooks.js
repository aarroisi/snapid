async function compressImage(file, maxWidth, maxHeight) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (event) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement("canvas");
        let width = img.width;
        let height = img.height;

        if (width > maxWidth || height > maxHeight) {
          const aspectRatio = width / height;
          if (width > maxWidth) {
            width = maxWidth;
            height = Math.round(width / aspectRatio);
          }
          if (height > maxHeight) {
            height = maxHeight;
            width = Math.round(height * aspectRatio);
          }
        }

        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0, width, height);

        canvas.toBlob((blob) => {
          const compressedFile = new File([blob], file.name, {
            type: file.type,
          });
          const compressedData = {
            file: compressedFile,
            width: width,
            height: height,
          };
          resolve(compressedData);
        }, file.type);
      };
      img.src = event.target.result;
    };
    reader.onerror = (error) => {
      reject(error);
    };
    reader.readAsDataURL(file);
  });
}

function uploadFileAttachment(attachment) {
  uploadFile(attachment.file, setProgress, setAttributes);

  function setProgress(progress) {
    attachment.setUploadProgress(progress);
  }

  function setAttributes(attributes) {
    attachment.setAttributes(attributes);
  }
}

function removeFileAttachment(url) {
  const xhr = new XMLHttpRequest();
  const formData = new FormData();
  formData.append("key", url);
  const csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");

  xhr.open("DELETE", "/trix-uploads", true);
  xhr.setRequestHeader("X-CSRF-Token", csrfToken);

  xhr.send(formData);
}

function generateSecureRandomString(length) {
  const characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";

  const randomBytes = new Uint8Array(length);
  crypto.getRandomValues(randomBytes);

  for (let i = 0; i < length; i++) {
    const randomIndex = randomBytes[i] % characters.length;
    result += characters.charAt(randomIndex);
  }

  return result;
}

function createStorageKey() {
  return generateSecureRandomString(32);
}

function createFormData(key, file) {
  var data = new FormData();
  data.append("key", key);
  data.append("Content-Type", file.type);
  data.append("file", file);
  return data;
}

function uploadFile(file, progressCallback, successCallback) {
  var key = createStorageKey();
  const formData = createFormData(key, file);
  const csrfToken = document
    .querySelector("meta[name='csrf-token']")
    .getAttribute("content");
  const xhr = new XMLHttpRequest();

  xhr.open("POST", "/trix-uploads", true);
  xhr.setRequestHeader("X-CSRF-Token", csrfToken);

  xhr.upload.addEventListener("progress", function (event) {
    if (event.lengthComputable) {
      const progress = Math.round((event.loaded / event.total) * 100);
      progressCallback(progress);
    }
  });

  xhr.addEventListener("load", function (_event) {
    if (xhr.status === 201) {
      const url = xhr.responseText;
      const attributes = { url, href: `${url}?content-disposition=attachment` };
      successCallback(attributes);
    }
  });

  xhr.send(formData);
}

export default {
  mounted() {
    const element = document.querySelector("trix-editor");

    element.editor.element.addEventListener("keydown", function (event) {
      if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
        const form = event.target.closest("form");
        if (form) {
          event.preventDefault();
          form.dispatchEvent(new Event("submit", { bubbles: true }));
        }
      }
    });

    element.editor.element.addEventListener("trix-change", (_e) => {
      this.el.dispatchEvent(new Event("change", { bubbles: true }));
    });

    element.editor.element.addEventListener(
      "trix-attachment-add",
      async function (event) {
        if (event.attachment.file) {
          const file = event.attachment.file;

          if (file.type.startsWith("image/")) {
            try {
              const maxWidth = 600;
              const maxHeight = 1800;
              const compressedData = await compressImage(
                file,
                maxWidth,
                maxHeight,
              );

              const { file: compressedFile, width, height } = compressedData;

              event.attachment.setAttributes({
                file: compressedFile,
                width: width,
                height: height,
                filesize: compressedFile.size,
              });

              uploadFileAttachment(event.attachment);
            } catch (error) {
              console.error(`Error compressing image ${file.name}:`, error);
            }
          } else {
            uploadFileAttachment(event.attachment);
          }
        }
      },
    );

    element.editor.element.addEventListener(
      "trix-attachment-remove",
      function (event) {
        removeFileAttachment(event.attachment.attachment.attributes.values.url);
      },
    );

    this.handleEvent("updateContent", (data) => {
      element.editor.loadHTML(data.content || "");
    });
  },
};
