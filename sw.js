self.addEventListener('push', function (event) {
  let data = { title: 'Bonny', body: '' };
  try { data = event.data.json(); } catch (e) {
    if (event.data) data.body = event.data.text();
  }
  const title = data.title || 'Bonny';
  const options = {
    body: data.body || '',
    icon: 'img/icon-192.png',
    badge: 'img/icon-192.png'
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', function (event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (clientList) {
      for (const client of clientList) {
        if ('focus' in client) return client.focus();
      }
      if (clients.openWindow) return clients.openWindow('./');
    })
  );
});
