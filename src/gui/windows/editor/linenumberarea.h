#ifndef LINENUMBERAREA_H
#define LINENUMBERAREA_H

#include "common/memory_ownership.h"

#include <QWidget>

class SrcEditor;

class LineNumberArea : public QWidget {
public:
    explicit LineNumberArea(BORROWED SrcEditor *editor_);

    [[nodiscard]] QSize sizeHint() const override;

protected:
    void paintEvent(QPaintEvent *event) override;

private:
    BORROWED SrcEditor *editor;
};

#endif // LINENUMBERAREA_H