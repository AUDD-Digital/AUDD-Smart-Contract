# Calendar Prototype Integration - Research Findings

**Generated**: 2026-02-02
**Purpose**: Consolidated research for integrating calendar prototype into unified production app
**Sources**: FRONT_END_UPGRADE_v1.md, FRONT_END_UPGRADE_v2.md, prototype documentation, codebase analysis

---

## Overview

This research document consolidates findings from analyzing:
1. The two FRONT_END_UPGRADE instruction documents
2. The calendar prototype codebase (`prototypes/calendar/`)
3. The unified production app (`frontend/admin/`)
4. Backend-related documentation in the prototype

The document is structured into two main sections:
1. **Part A**: Frontend prototype integration work (UI/UX improvements to fold into unified)
2. **Part B**: Backend requirements documented in prototype (not attached to UI, needs backend implementation)

---

## Key Principles (Synthesized from v1 and v2)

### From v2 (Higher Authority)
- **Current prototype is source of truth** for product behaviour
- **Treat as migration, not greenfield** - don't preserve old behaviour "just in case"
- **Flag ambiguity, don't guess** - list uncertainties rather than inventing solutions
- **Non-visual requirements from docs** - emails, webhooks, background jobs exist only in .md files

### From v1 (Backend Focus)
- Document exact calculations/logic from prototype code
- Identify what calculations happen frontend vs backend
- Define API contracts and data persistence requirements

---

# PART A: Frontend Prototype Integration

## A.1 Components Already in Unified

The following components have already been copied/implemented in unified:

| Component | Purpose | Status |
|-----------|---------|--------|
| AddOnsSection.tsx | Three-category add-on picker | Present |
| AdditionalPaymentPromptDialog.tsx | Amendment payment prompts | Present |
| BookingAmendmentConfirmationModal.tsx | Amendment confirmation | Present |
| BookingStatusBanner.tsx | Payment status display | Present |
| CheckInDialog.tsx | Customer arrival confirmation | Present |
| MergeBookingDialog.tsx | Combine bookings | Present |
| PaymentDetailsDialog.tsx | Invoice/receipt viewer | Present |
| ProcessRefundDialog.tsx | Refund processing | Present |
| ProcessRefundModal.tsx | Advanced refund selection | Present |
| RefundRequiredDialog.tsx | Overpayment refund handling | Present |
| RunningSheetDialog.tsx | Staff operational document | Present |
| ViewOnlyBookingDialog.tsx | Read-only merged booking view | Present |

## A.2 Utilities Already in Unified

| Utility | Purpose | Status |
|---------|---------|--------|
| bookingAmendment.ts | Amendment detection | Present |
| bookingDifference.ts | Diff calculation | Present |
| bowlsPricing.ts | Bowls green pricing | Present |
| areaHirePricing.ts | Area hire pricing | Present |
| areaHireMigration.ts | Legacy data migration | Present |
| fees.ts | Fee calculations | Present |
| feeCalculation.ts | Fee breakdowns | Present |
| quoteGeneration.ts | Quote item generation | Present |
| bookingColors.ts | Booking visual colors | Present |

## A.3 Components Missing from Unified (Need Integration)

### Critical Priority

| Component | Purpose | Why Critical |
|-----------|---------|--------------|
| **AmendmentIntentDialog.tsx** | Admin vs customer intent clarification | Prevents silent price change losses |
| **AcceptQuotePublicPage.tsx** | Customer-facing quote acceptance | Required for quote acceptance flow |
| **ActivePaymentLinkDialog.tsx** | View active payment link status | Payment link visibility |

### High Priority - External Payment System

| Component | Purpose |
|-----------|---------|
| ExternalPaymentDialog.tsx | Record non-Stripe payments |
| ExternalPaymentTimeline.tsx | Display external payment activity |
| ManualPaymentEntryDialog.tsx | Manual payment recording |
| MarkExternalPaymentPaidDialog.tsx | Mark external payments received |
| RecordExternalPaymentDialog.tsx | Record external payment details |
| PaymentTimelineActionsMenu.tsx | Timeline action menu |

### Medium Priority

| Component | Purpose |
|-----------|---------|
| UpdatePaymentLinkConfirmationModal.tsx | Payment link update confirmation |
| UpdateQuoteConfirmationModal.tsx | Quote update confirmation |
| DateChangeConfirmationDialog.tsx | Date change notification prompt |
| RecurringEditScopeDialog.tsx | Recurring booking edit scope selection |
| RefundDetailsModal.tsx | Detailed refund information view |
| NotifyGuestConfirmationModal.tsx | Guest notification confirmation |
| TimezoneIndicator.tsx | Timezone display component |
| BookingTypeChipSelect.tsx | Chip-based booking type selector |
| BookingsListView.tsx | List view for bookings |
| PricingRulesModal.tsx | Dynamic pricing rules management |

### Low Priority

| Component | Purpose |
|-----------|---------|
| email-templates/* | Email template preview components |

## A.4 Utilities Missing from Unified (Need Integration)

### Critical

| Utility | Purpose | Why Critical |
|---------|---------|--------------|
| **unifiedChangeDetection.ts** | Comprehensive amendment detection | Fixes green type change detection bug |
| **paymentStatusCalculator.ts** | Auto-calculate payment status | Accurate status derivation |
| **paymentStatusDisplay.ts** | Status display formatting | Consistent status UI |

### High Priority

| Utility | Purpose |
|---------|---------|
| externalPaymentCalculator.ts | External payment calculations |
| quoteVersioning.ts | Quote version management |
| timezone.ts | Timezone handling utilities |
| bookingStateSync.ts | State synchronization |

### Medium Priority

| Utility | Purpose |
|---------|---------|
| invoicePDFHelper.ts | PDF generation helpers |
| pdfGenerator.ts | PDF document generation |
| deepClone.ts | Deep object cloning utility |

## A.5 Type Definitions to Merge

From `prototypes/calendar/src/types/index.ts`:

1. **ExternalPayment** interface - Complete external payment tracking
2. **QuoteItemAmendment** interface - Amendment item tracking
3. **RefundRecord** with reason tracking
4. **BookingAmendment** with `type` field (quote_amendment vs booking_modification)
5. **QuoteActivity** with all activity types including payment link cancellations
6. **ClubConfiguration** with timezone/locale/currency fields

## A.6 Hooks Missing from Unified

| Hook | Purpose |
|------|---------|
| useBookingStateSync.ts | State synchronization hook |

---

# PART B: Backend Requirements (Non-UI Documentation)

These requirements are documented in the prototype's .md files but represent backend functionality that needs to be implemented. They are NOT attached to specific UI components.

## B.1 Stripe Integration Requirements

**Source**: `STRIPE_INTEGRATION_COMPLETE_GUIDE.md`

### Current Production State (Already Exists)
- Stripe Connect Standard with 27 connected accounts
- Variable fee infrastructure (0%, 3.0%, 3.3%, custom per club)
- 4 fee absorption strategies via admin toggles
- Webhooks: `payment_intent.succeeded`, `payment_intent.payment_failed`

### New Requirements for 2026 Pricing

1. **Tiered Pricing Implementation**
   ```
   < $1,000 booking:     3.3% fee
   $1,000 - $2,500:      2.2% fee
   > $2,500:             1.1% fee
   ```

2. **Monthly Subscription Plans**
   - $75/month + 1.1% per booking
   - $600/month + 0% per booking (enterprise)
   - Requires Stripe Subscriptions API integration

3. **Database Schema Updates**
   ```sql
   ALTER TABLE clubs
     ADD COLUMN pricing_plan VARCHAR(50) DEFAULT 'legacy_3.3',
     ADD COLUMN stripe_subscription_id VARCHAR(255) NULL,
     ADD COLUMN monthly_subscription_fee DECIMAL(10,2) DEFAULT 0,
     ADD COLUMN enterprise_fee_rate DECIMAL(4,2) DEFAULT 0;
   ```

4. **Gross-Up Formula Fix** (Bug in prototype)
   - Current prototype uses simple addition for Stripe fees
   - Production requires: `P_charge = (P_goal + F_fixed) / (1 - F_percent)`

## B.2 Stripe Refund API Integration

**Source**: `STRIPE_REFUND_IMPLEMENTATION_GUIDE.md`

### Refund Processing Requirements

1. **Multi-Payment Intent Refunds**
   - Stripe requires refunds against specific Payment Intents
   - Auto-split algorithm needed for refunds spanning multiple payments

2. **New Webhook Events**
   - `refund.created`
   - `refund.updated`
   - `refund.failed`

3. **Refund Data Structure**
   ```typescript
   interface RefundRecord {
     refundedFromPaymentId: string
     sourcePaymentIntentId: string
     stripeRefundId: string
     isPartOfSplitRefund: boolean
     splitRefundGroupId: string | null
   }
   ```

4. **Database Schema for Refunds**
   ```sql
   ALTER TABLE payments
     ADD COLUMN refundedFromPaymentId VARCHAR(255),
     ADD COLUMN sourcePaymentIntentId VARCHAR(255),
     ADD COLUMN stripeRefundId VARCHAR(255),
     ADD COLUMN isPartOfSplitRefund BOOLEAN DEFAULT FALSE,
     ADD COLUMN splitRefundGroupId VARCHAR(255);
   ```

## B.3 Email System Requirements

**Source**: `EMAIL_TEMPLATES.md`, `EMAIL_PAYMENT_SYSTEM.md`, `EMAIL_DEEP_LINKING.md`

### 16 Email Templates Required

| # | Template | Trigger |
|---|----------|---------|
| 1 | Quote Sent | Quote generated and sent |
| 2 | Deposit Payment Link | Deposit payment link created |
| 3 | Additional Payment Link | Final/additional payment link |
| 4 | Payment Reminder | Manual reminder sent |
| 5 | Payment Confirmation | Stripe `payment_intent.succeeded` |
| 6 | Booking Confirmation (Paid in Full) | Booking fully paid |
| 7 | Quote Cancelled | Quote cancelled before payment |
| 8 | Payment Link Cancelled | Payment link cancelled |
| 9 | Refund Processed | Refund completed |
| 10 | Amendment Quote | Amendment with price change |
| 11 | Resend Quote | Quote resent |
| 12 | Resend Payment Link | Payment link resent |
| 13 | Booking Time Change | Time changed (no price change) |
| 14 | Booking Date Change | Date changed (no price change) |
| 15 | Complimentary Upgrade | Free upgrade notification |
| 16 | Booking Merge | Bookings merged notification |

### Email Service Interface
```typescript
interface EmailService {
  sendInvoiceEmail(booking, invoice, config): Promise<EmailResult>
  sendQuoteEmail(booking, quote, config): Promise<EmailResult>
  sendPaymentConfirmation(booking, payment): Promise<EmailResult>
  sendPaymentReminder(booking, invoice): Promise<EmailResult>
  sendRefundNotification(booking, refund): Promise<EmailResult>
  sendEnquiryNotification(enquiry): Promise<EmailResult>
}
```

### Database Tables for Email
```sql
CREATE TABLE club_email_templates (
  id UUID PRIMARY KEY,
  club_id UUID REFERENCES clubs(id),
  template_type VARCHAR(50) NOT NULL,
  subject_template TEXT NOT NULL,
  body_template TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE email_logs (
  id UUID PRIMARY KEY,
  booking_id UUID REFERENCES bookings(id),
  club_id UUID REFERENCES clubs(id),
  email_type VARCHAR(50) NOT NULL,
  recipient_email VARCHAR(255) NOT NULL,
  stripe_payment_link_id VARCHAR(255),
  sent_at TIMESTAMP DEFAULT NOW(),
  status VARCHAR(20) DEFAULT 'sent'
);
```

### Quote Acceptance Deep Linking
- URL format: `/?acceptQuote=true&quoteId={BOOKING_ID}&token={SECURE_TOKEN}`
- Token generation: `generateQuoteAcceptanceToken(bookingId, quoteVersion)`
- Token expiry: 14 days (matches quote validity)

## B.4 PDF Generation Requirements

**Source**: `EMAIL_TEMPLATES.md`, `INVOICE_EMAIL_PDF_SYSTEM.md`

### Required PDFs
1. **Quote PDF** - Attached to quote emails
2. **Invoice PDF** - Attached to payment link emails
3. **Receipt PDF** - Attached to payment confirmation emails

### Technical Options
- **Option A**: Use Stripe's PDFs (recommended for receipts)
- **Option B**: Generate custom PDFs (required for quotes/invoices with branding)

### Recommended Hybrid Approach
- Quotes: Custom PDFs (pre-payment, custom branded)
- Invoices: Custom PDFs with Stripe data
- Receipts: Stripe's PDFs (tax-compliant, post-payment)

## B.5 Webhook Event Requirements

**Source**: `STRIPE_INTEGRATION_COMPLETE_GUIDE.md`, `EMAIL_PAYMENT_SYSTEM.md`

### Current Webhooks (Already Implemented)
- `payment_intent.succeeded` - Update booking status, send confirmation
- `payment_intent.payment_failed` - Error handling

### New Webhooks Required
- `checkout.session.completed` - Payment link payment completed
- `payment_link.expired` - Payment link expired
- `refund.succeeded` - Refund confirmed
- `refund.failed` - Refund failed
- `subscription.created` - Club subscription activated
- `subscription.deleted` - Club subscription cancelled
- `invoice.payment_succeeded` - Monthly subscription payment

## B.6 API Endpoints Required

**Source**: `PRODUCTION_INTEGRATION_STRATEGY.md`, various docs

### Booking Operations
```
POST   /bookings/:id/amendments      - Create booking amendment
PUT    /bookings/:id/payment-status  - Update payment status
GET    /bookings/:id/activity-timeline - Get full activity timeline
```

### External Payments
```
POST   /bookings/:id/external-payments - Record external payment
PUT    /external-payments/:id/mark-paid - Mark external payment paid
DELETE /external-payments/:id - Delete external payment
```

### Refunds
```
POST   /bookings/:id/refunds - Process refund
GET    /bookings/:id/refunds - Get refund history
```

### Quotes
```
POST   /bookings/:id/quotes - Generate new quote
PUT    /quotes/:id/accept - Accept quote (public endpoint)
PUT    /quotes/:id/cancel - Cancel quote
```

### Payment Links
```
POST   /bookings/:id/payment-links - Create payment link
DELETE /payment-links/:id - Cancel payment link
POST   /payment-links/:id/resend - Resend payment link email
```

### Club Configuration
```
GET    /clubs/:id/fee-configuration - Get fee settings
PUT    /clubs/:id/fee-configuration - Update fee settings
POST   /clubs/:id/subscription - Create subscription
DELETE /clubs/:id/subscription - Cancel subscription
```

## B.7 Business Rules for Backend

**Source**: `BUSINESS_RULES.md`

### Financial Rules
1. **Deposit Preservation**: Customer deposits NEVER lost through amendments
2. **GST Calculation**: `GST = Total / 11` (Australian standard)
3. **Payment Source of Truth**: `payments[]` array is definitive
4. **Fee Non-Refundability**: Stripe and Platform fees are retained on refunds

### Payment Status Calculation
```typescript
const calculatePaymentStatus = (booking) => {
  const totalPaid = sum(booking.payments.filter(p => p.amount > 0))
  const totalRefunded = sum(booking.payments.filter(p => p.type === 'refund').map(p => Math.abs(p.amount)))
  const netPaid = totalPaid - totalRefunded
  const currentTotal = booking.quoteData?.total || 0
  const remainingBalance = currentTotal - netPaid

  // Determine status based on state machine
}
```

### Amendment Scenarios
1. **No price change** → Save silently
2. **No payment yet** → Update & send new quote
3. **Quote/Payment link sent** → Cancel & resend
4. **Partial/Full payment with increase** → Intent clarification required
5. **Partial/Full payment with decrease** → Refund consideration

## B.8 Database Schema Changes Summary

### New Tables
- `club_fee_configs` - Fee configuration per club
- `club_email_templates` - Email templates per club
- `email_logs` - Email tracking
- `payment_links` - Payment link tracking

### Column Additions to `clubs`
- `pricing_plan`
- `stripe_subscription_id`
- `monthly_subscription_fee`
- `enterprise_fee_rate`
- `timezone`
- `locale`
- `currency`

### Column Additions to `payments`
- `refundedFromPaymentId`
- `sourcePaymentIntentId`
- `stripeRefundId`
- `isPartOfSplitRefund`
- `splitRefundGroupId`

### Column Additions to `bookings`
- `externalPayments` (JSON/JSONB)
- `hasExternalPayments`
- `paymentStatusCalculationMethod`
- `hasMixedPaymentMethods`

---

# Summary: Work Packages

## Package 1: Frontend Component Integration
- Copy missing components from prototype to unified
- Update imports and integrate with existing routing/state
- Focus: AmendmentIntentDialog, External Payment components

## Package 2: Frontend Utility Integration
- Copy missing utilities, especially unifiedChangeDetection.ts
- Merge type definitions
- Update existing utilities with prototype improvements

## Package 3: Backend - Stripe 2026 Pricing
- Implement tiered pricing logic
- Add Stripe Subscriptions for monthly plans
- Fix gross-up formula
- Add new webhooks

## Package 4: Backend - Refund System
- Implement auto-split refund algorithm
- Add refund webhook handlers
- Track refund-to-payment linkage

## Package 5: Backend - Email System
- Implement 16 email templates
- PDF generation service
- Email logging and tracking
- Deep-link quote acceptance

## Package 6: Backend - External Payments
- API endpoints for external payment CRUD
- Payment status calculation with mixed methods
- Activity timeline integration

## Package 7: Backend - API Contracts
- Implement all required endpoints
- Ensure data validation
- Error handling and responses

---

**Ready for /create_plan**
