#include <QGuiApplication>
#include <QQuickView>
#include <QAccessible>
#include <QAccessibleValueInterface>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QTimer>
#include <cstdio>
QJsonObject inspect(QAccessibleInterface *iface) {
    QJsonObject result;
    if (!iface) return result;
    result["name"] = iface->text(QAccessible::Name);
    result["description"] = iface->text(QAccessible::Description);
    result["role"] = int(iface->role());
    if (auto object = iface->object()) result["objectName"] = object->objectName();
    result["focused"] = bool(iface->state().focused);
    result["selected"] = bool(iface->state().selected);
    result["selectable"] = bool(iface->state().selectable);
    QJsonArray actions; if (iface->actionInterface()) for (const auto &action : iface->actionInterface()->actionNames()) actions.append(action); result["actions"] = actions;
    if (auto value = iface->valueInterface()) {
        result["value"] = QJsonValue::fromVariant(value->currentValue());
        result["minimum"] = QJsonValue::fromVariant(value->minimumValue());
        result["maximum"] = QJsonValue::fromVariant(value->maximumValue());
    }
    QJsonArray children;
    for (int i=0; i<iface->childCount(); ++i) children.append(inspect(iface->child(i)));
    result["children"] = children;
    return result;
}
int main(int argc, char **argv) {
    QGuiApplication app(argc, argv);
    if (argc != 2) return 2;
    QAccessible::setActive(true);
    QQuickView view;
    view.setSource(QUrl::fromLocalFile(QString::fromLocal8Bit(argv[1])));
    if (view.status() != QQuickView::Ready) return 1;
    view.show();
    QTimer::singleShot(100, [&]() {
        auto result = inspect(QAccessible::queryAccessibleInterface(&view));
        std::puts(QJsonDocument(result).toJson(QJsonDocument::Compact).constData());
        app.quit();
    });
    return app.exec();
}
