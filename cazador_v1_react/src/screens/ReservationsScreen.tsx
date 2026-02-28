import React from 'react';
import { View, Text, ScrollView, Pressable, StyleSheet } from 'react-native';
import { Plus, User } from 'lucide-react-native';
import { colors, spacing, borderRadius } from '../theme';
import type { Reservation } from '../types';

interface ReservationsScreenProps {
  reservations: Reservation[];
  onAddReservation: () => void;
}

function statusLabel(s: Reservation['status']) {
  if (s === 'confirmed') return 'Confirmada';
  if (s === 'pending') return 'Pendiente';
  return 'Cancelada';
}

export function ReservationsScreen({ reservations, onAddReservation }: ReservationsScreenProps) {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.title}>Reservas</Text>
        <Pressable onPress={onAddReservation} style={styles.addBtn}>
          <Plus size={18} color={colors.white} />
        </Pressable>
      </View>
      {reservations.map((res) => (
        <View key={res.id} style={styles.card}>
          <View style={styles.cardTop}>
            <View>
              <Text style={styles.projectName}>{res.projectName}</Text>
              <Text style={styles.unit}>Unidad: {res.unit}</Text>
            </View>
            <View style={[styles.badge, res.status === 'confirmed' ? styles.badgeOk : res.status === 'pending' ? styles.badgePending : styles.badgeCancel]}>
              <Text style={styles.badgeText}>{statusLabel(res.status)}</Text>
            </View>
          </View>
          <View style={styles.cardBottom}>
            <View style={styles.clientRow}>
              <View style={styles.avatar}>
                <User size={12} color={colors.zinc[400]} />
              </View>
              <Text style={styles.clientName}>{res.clientName}</Text>
            </View>
            <Text style={styles.amount}>${res.amount.toLocaleString()}</Text>
          </View>
        </View>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  content: { padding: spacing.lg, gap: spacing.sm },
  header: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  title: { fontSize: 20, fontWeight: '700', color: colors.zinc[900] },
  addBtn: { padding: spacing.sm, backgroundColor: colors.blue[600], borderRadius: borderRadius.xl },
  card: {
    backgroundColor: colors.white,
    padding: spacing.md,
    borderRadius: borderRadius.xl,
    borderWidth: 1,
    borderColor: colors.zinc[100],
    gap: spacing.sm,
  },
  cardTop: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' },
  projectName: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
  unit: { fontSize: 10, color: colors.zinc[500] },
  badge: { paddingHorizontal: 6, paddingVertical: 2, borderRadius: borderRadius.full },
  badgeOk: { backgroundColor: colors.emerald[100] },
  badgePending: { backgroundColor: colors.amber[100] },
  badgeCancel: { backgroundColor: colors.red[50] },
  badgeText: { fontSize: 8, fontWeight: '700' },
  cardBottom: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.zinc[50],
  },
  clientRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  avatar: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: colors.zinc[50],
    alignItems: 'center',
    justifyContent: 'center',
  },
  clientName: { fontSize: 10, fontWeight: '500', color: colors.zinc[600] },
  amount: { fontSize: 12, fontWeight: '700', color: colors.zinc[900] },
});
