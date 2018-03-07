/*
 * Copyright (c) 2005-2018, BearWare.dk
 * 
 * Contact Information:
 *
 * Bjoern D. Rasmussen
 * Kirketoften 5
 * DK-8260 Viby J
 * Denmark
 * Email: contact@bearware.dk
 * Phone: +45 20 20 54 59
 * Web: http://www.bearware.dk
 *
 * This source code is part of the TeamTalk SDK owned by
 * BearWare.dk. Use of this file, or its compiled unit, requires a
 * TeamTalk SDK License Key issued by BearWare.dk.
 *
 * The TeamTalk SDK License Agreement along with its Terms and
 * Conditions are outlined in the file License.txt included with the
 * TeamTalk SDK distribution.
 *
 */

#pragma once

#include "NGWizardPage.h"
#include "afxwin.h"

// CWizCompletionPage dialog

class CWizCompletionPage : public CNGWizardPage
{
    DECLARE_DYNAMIC(CWizCompletionPage)

public:
    CWizCompletionPage();
    virtual ~CWizCompletionPage();

    // Dialog Data
    enum { IDD = IDD_WIZARD_COMPLETIONPAGE };

protected:
    virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

    DECLARE_MESSAGE_MAP()
    CStatic m_wndTitle;
    CFont font1;

public:
    virtual BOOL OnInitDialog();
    virtual BOOL OnSetActive();
    BOOL m_bManual;
    BOOL m_bWebsite;
    CEdit m_wndComplete;
};